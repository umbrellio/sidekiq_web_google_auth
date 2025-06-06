# frozen_string_literal: true

# Idea taken from https://github.com/mperham/sidekiq/issues/2460#issuecomment-125694743
module SidekiqWebGoogleAuth
  class Extension
    class << self
      attr_accessor :authorized_emails, :authorized_emails_domains

      def valid_email?(email)
        authorized_emails.empty? || authorized_emails.include?(email)
      end

      def valid_email_domain?(email)
        authorized_emails_domains.empty? || authorized_emails_domains.include?(email[/(?<=@).+/])
      end

      def registered(app)
        app.get "/auth/page" do
          "Please <a href='#{root_path}auth/oauth'>authenticate via Google</a>."
        end

        app.get "/auth/oauth/callback" do
          auth = request.env["omniauth.auth"]
          ext = SidekiqWebGoogleAuth::Extension

          if auth && ext.valid_email?(auth.info.email) && ext.valid_email_domain?(auth.info.email)
            session[:authenticated] = true
            redirect(root_path)
          else
            OmniAuth.logger.warn(
              "Someone unauthorized is trying to gain access to Sidekiq: #{auth.info}",
            )
            redirect("#{root_path}auth/page")
          end
        end

        app.get "/logout" do
          session.clear
          redirect(root_path)
        end
      end
    end
  end
end
