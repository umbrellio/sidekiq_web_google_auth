# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "sidekiq_web_google_auth"
  spec.version       = "0.2.5"
  spec.authors       = ["Igor Kir"]
  spec.email         = ["igor.kir@cadolabs.io"]

  spec.summary       = "Google OAuth for Sidekiq::Web"
  spec.homepage      = "https://github.com/umbrellio/sidekiq_web_google_auth"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.2")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/umbrellio/sidekiq_web_google_auth"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth"
  spec.add_dependency "omniauth-google-oauth2"
  spec.add_dependency "sidekiq", ">= 8"
end
