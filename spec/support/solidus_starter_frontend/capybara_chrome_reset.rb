# frozen_string_literal: true

# Workaround for Capybara 3.40 + recent Chrome.
#
# Between tests Capybara's Chrome driver clears browser data with
#   Storage.clearDataForOrigin(origin: "*")
# Newer Chrome versions reject "*" ("invalid argument: * is not a valid URL"),
# which fails every JS system spec after the first one. Clear cookies globally
# and storage for the app server's real origin instead.
#
# Remove once a Capybara release stops sending the "*" origin.
module CapybaraChromeResetFix
  def execute_cdp(cmd, **params)
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")

    origin = Capybara.current_session.server&.base_url
    super(cmd, **params, origin: origin) if origin
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetFix)
