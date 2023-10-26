# frozen_string_literal: true

require 'fileutils'

module DoubleChecker
  class << self
    attr_accessor :gem_path, :repo_path, :result_path

    attr_writer :result_line_width

    def config
      yield self
    end

    def result_line_width
      @result_line_width || 50
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
      gem_line_arr = create_line_array(gem_path + file_path)
      repo_line_arr = create_line_array(repo_path + file_path)      
      
      if gem_line_arr.length > repo_line_arr.length
        (gem_line_arr.length - repo_line_arr.length).times do
          repo_line_arr.append("")
        end
      end

      zipped = repo_line_arr.zip(gem_line_arr)

      max_length = 0
      zipped.flatten.map do |line|
        if !line.nil? && line.length > max_length
          max_length = line.length
        end
      end

      self.result_line_width = max_length

      text_to_write = ""

      header = 
      <<~EOS
      #{"   |" + " " * (self.result_line_width / 2)}REPO#{" " * (self.result_line_width / 2)}||#{" " * (self.result_line_width / 2)}GEM#{" " * (self.result_line_width / 2)}
      #{"-" * (self.result_line_width * 2 + 10)}
      EOS

      text_to_write += header

      zipped.each_with_index do |couplet,index|
        text_to_write += "#{(index + 1).to_s.ljust(2, " ")} | #{couplet.first} #{" " * (self.result_line_width - couplet.first.length)} || #{couplet.last}"
        text_to_write += "\n"
      end
      
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
