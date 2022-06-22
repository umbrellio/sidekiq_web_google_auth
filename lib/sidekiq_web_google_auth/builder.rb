# frozen_string_literal: true

require_relative "extension"

module SidekiqWebGoogleAuth
  class Builder < OmniAuth::Builder
    def provider(*args, authorized_emails:, **options, &block)
      super("google_oauth2", *[*args, options.merge(name: "oauth")], &block)
      Sidekiq::Web.register(SidekiqWebGoogleAuth::Extension.new(authorized_emails))
    end
  end
end
