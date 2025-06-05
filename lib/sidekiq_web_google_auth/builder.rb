# frozen_string_literal: true

require_relative "extension"

module SidekiqWebGoogleAuth
  class Builder < OmniAuth::Builder
    class ArgumentError < StandardError; end

    ARGUMENT_ERROR = "You must provide authorized_emails or authorized_emails_domains (or both)"

    def provider(config, *args, authorized_emails: [], authorized_emails_domains: [], **options, &block)
      invalid_arguments! if authorized_emails.empty? && authorized_emails_domains.empty?
      super("google_oauth2", *args, options.merge(name: "oauth"), &block)

      SidekiqWebGoogleAuth::Extension.authorized_emails = authorized_emails
      SidekiqWebGoogleAuth::Extension.authorized_emails_domains = authorized_emails_domains
      config.register(SidekiqWebGoogleAuth::Extension, name: "google-auth", tab: [], index: [])
    end

    private

    def invalid_arguments!
      raise ArgumentError.new(ARGUMENT_ERROR)
    end
  end
end
