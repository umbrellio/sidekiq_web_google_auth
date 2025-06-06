# frozen_string_literal: true

require_relative "extension"

module SidekiqWebGoogleAuth
  class Builder < Rack::Builder
    def initialize(app, _options = nil)
      @app = app
    end

    def call(env)
      accept?(env) ? admit(env) : deny(env)
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
  end
end
