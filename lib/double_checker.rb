# frozen_string_literal: true

require 'fileutils'

module DoubleChecker
  class << self
    attr_accessor :gem_path, :repo_path, :result_path

    def config
      yield self
    end

    def folders_in_repo(relative_path)
      full_path_array = Dir.glob("#{repo_path + relative_path}/**").select { |f| File.directory?(f) }
      full_path_array.map { |fp| fp.split(repo_path).last }
    end

    def files_in_repo(relative_path)
      full_path_array = Dir.glob("#{repo_path + relative_path}/**").reject { |f| File.directory?(f) }
      full_path_array.map { |fp| fp.split(repo_path).last }
    end

    def folders_in_gem(relative_path)
      full_path_array = Dir.glob("#{gem_path + relative_path}/**").select { |f| File.directory?(f) }
      full_path_array.map { |fp| fp.split(gem_path).last }
    end

    def files_in_gem(relative_path)
      full_path_array = Dir.glob("#{gem_path + relative_path}/**").reject { |f| File.directory?(f) }
      full_path_array.map { |fp| fp.split(gem_path).last }
    end

    def folder_overlap(relative_path)
      folders_in_gem(relative_path) & folders_in_repo(relative_path)
    end

    def file_overlap(relative_path)
      files_in_gem(relative_path) & files_in_repo(relative_path)
    end

    def full_overlap_file_array(start_path = '', overlap_arr = [])
      file_overlap(start_path).each do |path|
        overlap_arr << path
      end

      folder_overlap(start_path).each do |path|
        full_overlap_file_array(path, overlap_arr)
      end

      overlap_arr
    end

    def create_result_folder
      FileUtils.mkdir_p(result_path)
    end

    def copy_gem_file(file_path)
      FileUtils.cp((gem_path + file_path).to_s, "#{result_path}/#{file_path}/GEM_#{file_path.split('/').last}")
    end

    def copy_repo_file(file_path)
      FileUtils.cp((repo_path + file_path).to_s, "#{result_path}/#{file_path}/REPO_#{file_path.split('/').last}")
    end

    def create_line_array(file_path)
      result_arr = []
      File.foreach(file_path).with_index do |line, line_num|
        result_arr << line.to_s.chomp
      end
      result_arr
    end

    def lines_only_in_gem(file_path)
      gem_line_arr = create_line_array(gem_path + file_path)
      repo_line_arr = create_line_array(repo_path + file_path)
      gem_line_arr - (gem_line_arr & repo_line_arr)
    end

    def lines_only_in_repo(file_path)
      gem_line_arr = create_line_array(gem_path + file_path)
      repo_line_arr = create_line_array(repo_path + file_path)
      repo_line_arr - (gem_line_arr & repo_line_arr)
    end

    def create_comparision_file(file_path)
      width = 20

      gem_line_arr = create_line_array(gem_path + file_path)
      repo_line_arr = create_line_array(repo_path + file_path)

      text_to_write = ""

      header = 
      <<~EOS
      #{" " * width}REPO#{" " * width}||#{" " * width}GEM#{" " * width}
      #{"-" * (width * 4) + "-" * 7}
      EOS

      text_to_write += header

      gem_line_arr.each_with_index do |line, line_num|
        if line == create_line_array(repo_path + file_path)[line_num]
          text_to_write += (line_num.to_s + " -- " + line + "\n")
        end
        # text_to_write += (line_num.to_s + " -- ")
      end

      # lines_only_in_gem(file_path).each_with_index do |line, line_num|
      #   text_to_write += (line_num.to_s + "---" + line + "\n")
      # end

      File.write(result_path + file_path + "/DIFF.txt", text_to_write)
    end

    def generate_result_folder
      create_result_folder

      full_overlap_file_array.each do |file_path|
        FileUtils.mkdir_p("#{result_path}/#{file_path}")
        copy_gem_file(file_path)
        copy_repo_file(file_path)
        create_comparision_file(file_path)
      end
    end
  end
end
