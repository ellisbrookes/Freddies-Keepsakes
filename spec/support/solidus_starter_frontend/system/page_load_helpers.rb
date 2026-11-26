# frozen_string_literal: true

module SolidusStarterFrontend
  module System
    # Helpers for clicks that submit a form and load a new page.
    #
    # With a real browser, `click_on` returns as soon as the click happens,
    # before the next page has loaded. Clicking again or calling `visit` straight
    # away can then cancel the request still in flight, which makes specs flaky.
    module PageLoadHelpers
      # Clicks a button, then waits for the browser to load a new page.
      def click_and_wait_for_page_load(locator, **options)
        # Rack::Test handles requests synchronously, so there's nothing to wait for.
        return click_button(locator, **options) if page.driver.is_a?(Capybara::RackTest::Driver)

        # Tag the current document; the tag disappears once a new document loads.
        page.execute_script("document.documentElement.dataset.pendingPageLoad = 'true'")
        click_button(locator, **options)
        expect(page).to have_no_css("html[data-pending-page-load]", wait: Capybara.default_max_wait_time * 2)
      end

      def save_and_continue
        click_and_wait_for_page_load("Save and Continue")
      end

      # Adds the product on the current page to the cart and waits for the cart page.
      def add_to_cart
        click_button "add-to-cart-button"
        expect(page).to have_current_path(cart_path)
      end
    end
  end
end

RSpec.configure do |config|
  config.include SolidusStarterFrontend::System::PageLoadHelpers, type: :system
end
