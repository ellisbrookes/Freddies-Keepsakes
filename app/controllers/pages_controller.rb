# frozen_string_literal: true

# Simple content pages linked from the footer (policies, help, etc.).
# Each page's content lives in app/views/pages/<slug>.html.erb.
class PagesController < StoreController
  PAGES = {
    "contact" => "Contact Us",
    "delivery" => "Delivery Information",
    "returns" => "Returns & Refunds",
    "faqs" => "FAQs",
    "privacy-policy" => "Privacy Policy",
    "terms" => "Terms & Conditions",
    "cookie-policy" => "Cookie Policy",
  }.freeze

  def show
    @slug = params[:page]
    @title = PAGES.fetch(@slug) { raise ActionController::RoutingError, "Not Found" }
    render @slug.underscore
  end

  private

  def accurate_title
    @title
  end
end
