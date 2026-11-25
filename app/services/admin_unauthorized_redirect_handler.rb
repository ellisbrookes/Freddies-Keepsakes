# frozen_string_literal: true

# Sends logged-out visitors of admin pages to the admin login screen
# (and back to the page they wanted after signing in). Logged-in users
# without admin rights get Solidus's standard "unauthorized" behaviour.
class AdminUnauthorizedRedirectHandler < Spree::UnauthorizedRedirectHandler
  def call
    return super if controller.send(:spree_current_user)

    Spree::UserLastUrlStorer.new(controller).store_location
    controller.redirect_to controller.spree.admin_login_path
  end
end
