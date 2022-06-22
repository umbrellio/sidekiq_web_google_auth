# frozen_string_literal: true

require "omniauth"

OmniAuth.config.allowed_request_methods = [:get]
OmniAuth.config.silence_get_warning = true

module SidekiqWebGoogleAuth
  require_relative "sidekiq_web_google_auth/builder"
end
