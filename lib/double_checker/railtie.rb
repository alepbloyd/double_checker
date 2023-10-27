module DoubleChecker
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/double_checker_tasks.rake'
    end
  end
end