require 'rake'
require "#{Rails.root}/config/double_checker" if File.exist?("#{Rails.root}/config/double_checker.rb")

namespace :double_checker do
  task :run do
    DoubleChecker.generate_result_folder
  end
end