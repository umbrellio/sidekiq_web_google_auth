# frozen_string_literal: true

require_relative "extension"

module SidekiqWebGoogleAuth
  class Builder < OmniAuth::Builder
    class ArgumentError < StandardError; end

    ARGUMENT_ERROR = "You must provide authorized_emails or authorized_emails_domains (or both)"

    def initialize(app, _options = nil)
      @app = app
    end

    def call(env)
      accept?(env) ? admit(env) : deny(env)
    end

    def provider(*args, **options, &block)
      super("google_oauth2", *args, options.merge(name: "oauth"), &block)
    end

    private

    def accept?(env)
      return true if env["PATH_INFO"].start_with?("/auth")
      session(env)[:authenticated]
    end

    def admit(env)
      @app.call(env)
    end

    def deny(env)
      [302, { "Location" => "#{env["SCRIPT_NAME"]}/auth/page" }, ["Found"]]
    end

    def session(env)
      env["rack.session"]
    end

    def invalid_arguments!
      raise ArgumentError.new(ARGUMENT_ERROR)
    end
  end
end
