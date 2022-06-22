# frozen_string_literal: true

# Idea taken from https://github.com/mperham/sidekiq/issues/2460#issuecomment-125694743
module SidekiqWebGoogleAuth
  class Extension
    def initialize(authorized_emails)
      @authorized_emails = authorized_emails
    end

    def registered(app) # rubocop:disable Metrics/MethodLength
      authorized_emails = @authorized_emails

      app.before do
        if !session[:authenticated] && !request.path_info.start_with?("/auth")
          redirect("#{root_path}auth/page")
        end
      end

      app.get "/auth/page" do
        "Please <a href='#{root_path}auth/oauth'>authenticate via Google</a>."
      end

      app.get "/auth/oauth/callback" do
        auth = request.env["omniauth.auth"]

        if auth && authorized_emails.include?(auth.info.email)
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

      app.tabs["Logout"] = "logout"
    end
  end
end
