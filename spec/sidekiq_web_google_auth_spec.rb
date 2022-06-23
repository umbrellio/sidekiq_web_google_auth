# frozen_string_literal: true

require "sidekiq/web"
require "rack/test"

RSpec.describe SidekiqWebGoogleAuth do
  include Rack::Test::Methods

  def perform_oauth!
    get("/")
    expect(last_response.status).to eq(302)
    expect(last_response.header["Location"]).to eq("http://example.org#{auth_page_url}")

    get(auth_page_url)
    expect(last_response.body).to include("<a href='#{omniauth_url}'>")

    get(omniauth_url)
    expect(last_response.status).to eq(302)
    expect(last_response.header["Location"]).to eq("http://example.org#{callback_url}")

    get(callback_url)
  end

  let(:app) do
    Sidekiq::Web.new.tap do |app|
      options = args
      app.middlewares.clear
      app.use(Rack::Session::Cookie, secret: "test")
      app.use(SidekiqWebGoogleAuth::Builder) do
        provider(
          "test_client_id",
          "test_client_secret",
          **options,
        )
      end
    end
  end

  let(:args) do
    { authorized_emails: %w[test@mail.com] }
  end

  let(:auth_page_url) { "/auth/page" }
  let(:omniauth_url) { "/auth/oauth" }
  let(:callback_url) { "/auth/oauth/callback" }
  let(:callback_email) { "test@mail.com" }

  before { OmniAuth.config.add_mock(:oauth, info: { email: callback_email }) }

  after { OmniAuth.config.mock_auth[:oauth] = nil }

  shared_examples "authenticates user" do
    specify do
      perform_oauth!
      expect(last_response.status).to eq(302)
      expect(last_response.header["Location"]).to eq("http://example.org/")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_truthy
    end
  end

  shared_examples "doesn't authenticate user" do
    specify do
      perform_oauth!
      expect(last_response.status).to eq(302)
      expect(last_response.header["Location"]).to eq("http://example.org#{auth_page_url}")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_falsey
    end
  end

  context "without args" do
    let(:args) do
      {}
    end

    it "raises error" do
      expect { perform_oauth! }.to raise_error(
        SidekiqWebGoogleAuth::Builder::ArgumentError,
        "You must provide authorized_emails or authorized_emails_domains (or both)",
      )
    end
  end

  context "with only authorized_emails" do
    it_behaves_like "authenticates user"

    context "non-listed email in callback" do
      let(:callback_email) { "wrong@example.com" }

      it_behaves_like "doesn't authenticate user"
    end
  end

  context "with only authorized_emails_domains" do
    let(:args) do
      { authorized_emails_domains: %w[mail.com] }
    end

    it_behaves_like "authenticates user"

    context "non-listed email domain" do
      let(:callback_email) { "test@example.com" }

      it_behaves_like "doesn't authenticate user"
    end
  end

  context "with both authorized_emails and authorized_emails_domains" do
    let(:args) do
      {
        authorized_emails: %w[test@mail.com],
        authorized_emails_domains: %w[mail.com],
      }
    end

    it_behaves_like "authenticates user"

    context "non-listed email" do
      let(:args) do
        {
          authorized_emails: %w[other@mail.com],
          authorized_emails_domains: %w[mail.com],
        }
      end

      it_behaves_like "doesn't authenticate user"
    end

    context "non-listed email domain" do
      let(:args) do
        {
          authorized_emails: %w[test@mail.com],
          authorized_emails_domains: %w[example.com],
        }
      end

      it_behaves_like "doesn't authenticate user"
    end
  end

  context "logging out" do
    it "clears user session and redirect to root" do
      perform_oauth!
      expect(last_request.env.dig("rack.session", "authenticated")).to be_truthy
      get("/logout")
      expect(last_response.status).to eq(302)
      expect(last_response.header["Location"]).to eq("http://example.org/")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_falsey
    end
  end
end
