require 'double_checker'

DoubleChecker.config do |c|
  c.gem_path = "#{Gem.dir}/gems/hyrax-3.6.0"
  c.repo_path = "#{Rails.root}"
  c.result_path = "#{Rails.root}/spec/double_checker_results"
  c.ignore_file = "#{Rails.root}/.double_checker_ignore"
end