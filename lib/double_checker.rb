# frozen_string_literal: true

module DoubleChecker
  class << self
    attr_accessor :gem_path, :repo_path, :result_path

    def config
      yield self
    end
  end
end
