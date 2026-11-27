# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Delivery and FAQ pages", type: :request do
  let!(:store) { create(:store) }

  def page_text
    Nokogiri::HTML(response.body).at_css("main").text.squish
  end

  describe "delivery information" do
    let!(:standard) { create(:shipping_method, name: "Standard delivery (2–4 working days)", cost: 3.99) }

    it "lists the delivery options and prices customers can choose at checkout" do
      create(:shipping_method, name: "Staff collection", cost: 0, available_to_users: false)

      get "/delivery"

      expect(response).to have_http_status(:ok)
      expect(page_text).to include("Standard delivery (2–4 working days) £3.99")
      expect(page_text).not_to include("Staff collection")
    end

    it "follows price changes made in the admin" do
      standard.calculator.update!(preferred_amount: 2.50)

      get "/delivery"

      expect(page_text).to include("£2.50")
      expect(page_text).not_to include("£3.99")
    end

    it "says prices are shown at checkout when there are no delivery options yet" do
      standard.destroy!

      get "/delivery"

      expect(page_text).to include("Delivery options and prices are shown at checkout.")
    end

    it "highlights the making times still to be filled in" do
      get "/delivery"

      expect(Nokogiri::HTML(response.body).css("mark.fill-in-later").size).to eq(2)
    end
  end

  describe "FAQs" do
    it "answers the common questions, with working links" do
      get "/faqs"

      doc = Nokogiri::HTML(response.body)
      expect(response).to have_http_status(:ok)
      expect(doc.css("details").size).to be >= 10
      expect(page_text).to include("Up to #{Personalisation::MAX_LENGTH} characters", "Do you deliver outside the UK?")
      expect(doc.css("details a").map { |a| a["href"] }).to include(contact_page_path, delivery_page_path, returns_page_path)
      expect(response.body).not_to include("&lt;a ")
    end
  end
end
