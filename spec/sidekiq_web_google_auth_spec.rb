# frozen_string_literal: true

require "sidekiq/web"
require "rack/test"
require "rack/session"

RSpec.describe SidekiqWebGoogleAuth do
  include Rack::Test::Methods

  def reset!
    cfg = Sidekiq::Config.new
    cfg[:backtrace_cleaner] = Sidekiq::Config::DEFAULTS[:backtrace_cleaner]
    cfg.logger = Logger.new(IO::NULL)
    cfg.logger.level = Logger::WARN
    Sidekiq.instance_variable_set :@config, cfg
    cfg
  end

  def app
    @app ||= Rack::Lint.new(Sidekiq::Web.new)
  end

  def perform_oauth!
    get("/")
    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq(auth_page_url)

    get(auth_page_url)
    expect(last_response.body).to include("<a href='#{omniauth_url}'>")

    get(omniauth_url)
    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq("http://example.org#{callback_url}")

    get(callback_url)
  end

  before do
    @config = reset!

    Sidekiq::Web.configure do |c|
      c.middlewares.clear

      secrets = "35c5108120cb479eecb4e947e423cad6da6f38327cf0ebb323e30816d74fa01f"
      c.use(Rack::Session::Cookie, secrets:)

      c.use(OmniAuth::Builder) do
        provider(:google_oauth2, "test_client_id", "test_client_secret", name: "oauth")
      end

      SidekiqWebGoogleAuth::Extension.authorized_emails = authorized_emails
      SidekiqWebGoogleAuth::Extension.authorized_emails_domains = authorized_emails_domains
      c.register(
        SidekiqWebGoogleAuth::Extension, name: "google-auth", tab: ["Logout"], index: ["logout"]
      )

      c.use(SidekiqWebGoogleAuth::Builder)
    end
  end

  let(:auth_page_url) { "/auth/page" }
  let(:omniauth_url) { "/auth/oauth" }
  let(:callback_url) { "/auth/oauth/callback" }
  let(:callback_email) { "test@mail.com" }
  let(:authorized_emails) { %w[test@mail.com] }
  let(:authorized_emails_domains) { %w[mail.com] }

  before { OmniAuth.config.add_mock(:oauth, info: { email: callback_email }) }

  after { OmniAuth.config.mock_auth[:oauth] = nil }

  shared_examples "authenticates user" do
    specify do
      perform_oauth!
      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq("http://example.org/")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_truthy
    end
  end

  shared_examples "doesn't authenticate user" do
    specify do
      perform_oauth!
      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq("http://example.org#{auth_page_url}")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_falsey
    end
  end

  context "with only authorized_emails" do
    let(:authorized_emails_domains) { [] }

    it_behaves_like "authenticates user"

    context "non-listed email in callback" do
      let(:callback_email) { "wrong@example.com" }

      it_behaves_like "doesn't authenticate user"
    end
  end

  context "with only authorized_emails_domains" do
    let(:authorized_emails) { [] }

    it_behaves_like "authenticates user"

    context "non-listed email domain" do
      let(:callback_email) { "test@example.com" }

      it_behaves_like "doesn't authenticate user"
    end
  end

  context "with both authorized_emails and authorized_emails_domains" do
    let(:authorized_emails) { %w[test@mail.com] }
    let(:authorized_emails_domains) { %w[mail.com] }

    it_behaves_like "authenticates user"

    context "non-listed email" do
      let(:authorized_emails) { %w[other@mail.com] }

      it_behaves_like "doesn't authenticate user"
    end

    context "non-listed email domain" do
      let(:authorized_emails_domains) { %w[example.com] }

      it_behaves_like "doesn't authenticate user"
    end
  end

  context "logging out" do
    it "clears user session and redirect to root" do
      perform_oauth!
      expect(last_request.env.dig("rack.session", "authenticated")).to be_truthy
      get("/logout")
      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq("http://example.org/")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_falsey
    end
  end
end
