# frozen_string_literal: true

# Give the admin login / forgot-password / reset-password pages their own
# centred, full-page layout (app/views/spree/layouts/admin_auth.html.erb)
# instead of the admin layout, whose sidebar and header are empty when
# nobody is signed in.
Rails.application.config.to_prepare do
  Spree::Admin::UserSessionsController.layout "spree/layouts/admin_auth"
  Spree::Admin::UserPasswordsController.layout "spree/layouts/admin_auth"
end
