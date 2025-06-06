# frozen_string_literal: true

require "omniauth"
require "omniauth-google-oauth2"

OmniAuth.config.allowed_request_methods = [:get]
OmniAuth.config.silence_get_warning = true

module SidekiqWebGoogleAuth
  require_relative "sidekiq_web_google_auth/builder"
  require_relative "sidekiq_web_google_auth/extension"

  def self.load(config, client_id:, client_secret:, authorized_emails:, authorized_emails_domains:)
    config.use(OmniAuth::Builder) do
      provider(:google_oauth2, client_id, client_secret, name: "oauth")
    end

    SidekiqWebGoogleAuth::Extension.authorized_emails = authorized_emails
    SidekiqWebGoogleAuth::Extension.authorized_emails_domains = authorized_emails_domains
    config.register(
      SidekiqWebGoogleAuth::Extension, name: "google-auth", tab: ["Logout"], index: ["logout"]
    )

    config.use(SidekiqWebGoogleAuth::Builder)
  end
end
