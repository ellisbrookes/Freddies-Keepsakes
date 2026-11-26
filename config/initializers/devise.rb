# frozen_string_literal: true

# Devise derives its secret from Rails' secret_key_base (credentials or the
# SECRET_KEY_BASE env var), so no key is hard-coded here.
Devise.email_regexp = Spree::Config.default_email_regexp
Devise.setup do |config|
  config.parent_controller = "StoreDeviseController"
  config.mailer = "UserMailer"
end
