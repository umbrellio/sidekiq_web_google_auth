# SidekiqWebGoogleAuth
[![Build Status](https://travis-ci.org/umbrellio/sidekiq_web_google_auth.svg?branch=master)](https://travis-ci.org/umbrellio/sidekiq_web_google_auth)
[![Coverage Status](https://coveralls.io/repos/github/umbrellio/sidekiq_web_google_auth/badge.svg?branch=master)](https://coveralls.io/github/umbrellio/sidekiq_web_google_auth?branch=master)
[![Gem Version](https://badge.fury.io/rb/sidekiq_web_google_auth.svg)](https://badge.fury.io/rb/sidekiq_web_google_auth)

Google OAuth for Sidekiq::Web

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq_web_google_auth'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sidekiq_web_google_auth

## Usage

Initialize builder:

```ruby
SidekiqWebGoogleAuth.setup!(
  client_id: "example_client_id", # Google OAuth client ID
  client_secret: "example_client_secret", # Google OAuth secret
  # You must provide at least one of: authorized_emails, authorized_email_domains
  authorized_emails: %w[test@mail.com], # List of authorized emails
  authorized_emails_domains: %w[mail.com], # List of authorized emails domains
)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/umbrellio/sidekiq_web_google_auth.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Authors

Team Umbrellio

---

<a href="https://github.com/umbrellio/">
<img style="float: left;" src="https://umbrellio.github.io/Umbrellio/supported_by_umbrellio.svg" alt="Supported by Umbrellio" width="439" height="72">
</a>
