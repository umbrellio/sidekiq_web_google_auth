Gem::Specification.new do |spec|
  spec.name          = "sidekiq_web_google_auth"
  spec.version       = "0.1.0"
  spec.authors       = ["Igor Kir"]
  spec.email         = ["igor.kir@cadolabs.io"]

  spec.summary       = "Google OAuth for Sidekiq::Web"
  spec.homepage      = "https://github.com/umbrellio/sidekiq_web_google_auth"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/umbrellio/sidekiq_web_google_auth"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "omniauth"
  spec.add_runtime_dependency "omniauth-google-oauth2"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sidekiq"
  spec.add_development_dependency "rack-test"
end
