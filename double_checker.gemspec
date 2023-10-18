require File.expand_path("lib/double_checker/version", __dir__)

Gem::Specification.new do |spec|
  spec.name                  = "double_checker"
  spec.version               = DoubleChecker::version
  spec.authors               = ["Alex Boyd"]
  spec.email                 = ["alex.boyd@gwu.edu"]
  spec.summary               = "Gem for comparing file overrides while using a Rails engine."
  spec.license               = "MIT"
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.6.0"

  spec.files                 = Dir["README.md", "LICENSE", "CHANGELOG.md". 
                                  "lib/**/*.rb", "lib/**/*.rake",
                                  "double_checker.gemspec"]
end