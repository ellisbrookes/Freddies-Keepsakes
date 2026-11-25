# frozen_string_literal: true

# Simple content pages linked from the footer (policies, help, etc.).
# Each page's content lives in app/views/pages/<template>.html.erb.
class PagesController < StoreController
  PAGES = {
    "contact" => { title: "Contact Us", template: "pages/contact" },
    "delivery" => { title: "Delivery Information", template: "pages/delivery" },
    "returns" => { title: "Returns & Refunds", template: "pages/returns" },
    "faqs" => { title: "FAQs", template: "pages/faqs" },
    "privacy-policy" => { title: "Privacy Policy", template: "pages/privacy_policy" },
    "terms" => { title: "Terms & Conditions", template: "pages/terms" },
    "cookie-policy" => { title: "Cookie Policy", template: "pages/cookie_policy" }
  }.freeze

  def show
    page = PAGES.fetch(params[:page]) { raise ActionController::RoutingError, "Not Found" }
    @title = page[:title]
    render template: page[:template]
  end

  private

  def accurate_title
    @title
  end
end
