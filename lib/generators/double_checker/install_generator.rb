# frozen_string_literal: true

require 'rails/generators'

module DoubleChecker
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Create a config/double_checker.rb file and /.double_checker_ignore file'

      def copy_config
        template 'double_checker_config.rb', "#{Rails.root}/config/double_checker.rb"
      end

      def copy_ignore_file
        template '.double_checker_ignore', "#{Rails.root}/.double_checker_ignore"
      end
    end
  end
end
