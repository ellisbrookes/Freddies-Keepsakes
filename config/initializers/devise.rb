# frozen_string_literal: true

Devise.secret_key = '569ba912233d2191fc244b28673f28c434d8d60a2d884d4ccd503e665dd780072a51f6ff22793c6dfa6bf36b382fe76d5aa8f2e54e8f0a35875c22d01ea7ca8b'
Devise.email_regexp = Spree::Config.default_email_regexp
Devise.setup do |config|
  config.parent_controller = 'StoreDeviseController'
  config.mailer = 'UserMailer'
end
