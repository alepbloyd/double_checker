# frozen_string_literal: true

module DoubleChecker
  class << self
    attr_accessor :gem_path, :repo_path, :result_path

    # Allow setting configs via block
    def config
      yield self
    end

    # Generates array of folders in a given path
    def folders_in_repo(relative_path)
      full_path_array = Dir.glob("#{repo_path + relative_path}/**").select { |f| File.directory?(f) }
      full_path_array.map { |fp| fp.split(repo_path).last }
    end

    # Generates array of files in a given path
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

    # Given relative path, return folders in both gem and repo
    def folder_overlap(relative_path)
      folders_in_gem(relative_path) & folders_in_repo(relative_path)
    end

    # Given relative path, return files in both gem and repo
    def file_overlap(relative_path)
      files_in_gem(relative_path) & files_in_repo(relative_path)
    end
  end
end
