# frozen_string_literal: true

require "sidekiq/web"
require "rack/test"

RSpec.describe SidekiqWebGoogleAuth do
  include Rack::Test::Methods

  def app
    Sidekiq::Web.new.tap do |app|
      app.use(Rack::Session::Cookie, secret: "test")
      app.use(SidekiqWebGoogleAuth::Builder) do
        provider(
          "test_client_id",
          "test_client_secret",
          authorized_emails: %w[test@mail.com],
        )
      end
    end
  end

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

  let(:auth_page_url) { "/auth/page" }
  let(:omniauth_url) { "/auth/oauth" }
  let(:callback_url) { "/auth/oauth/callback" }
  let(:callback_email) { "test@mail.com" }

  before { OmniAuth.config.add_mock(:oauth, info: { email: callback_email }) }

  after { OmniAuth.config.mock_auth[:oauth] = nil }

  it "authenticates user" do
    perform_oauth!
    expect(last_response.status).to eq(302)
    expect(last_response.header["Location"]).to eq("http://example.org/")
    expect(last_request.env.dig("rack.session", "authenticated")).to be_truthy
  end

  context "non-listed email in callback" do
    let(:callback_email) { "wrong@example.com" }

    it "doesn't authenticate user" do
      perform_oauth!
      expect(last_response.status).to eq(302)
      expect(last_response.header["Location"]).to eq("http://example.org#{auth_page_url}")
      expect(last_request.env.dig("rack.session", "authenticated")).to be_falsey
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
