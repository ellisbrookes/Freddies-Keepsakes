# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Legal pages", type: :request do
  let!(:store) { create(:store) }

  def page_text
    Nokogiri::HTML(response.body).at_css("main").text.squish
  end

  {
    "/returns" => [ "can't be returned just because you've changed your mind", "within 14 days of receiving it", "30 days" ],
    "/privacy-policy" => [ "data controller", "Information Commissioner's Office", "I'll never sell your information" ],
    "/cookie-policy" => [ "_freddies_personalised_boutique_session", "guest_token", "remember_spree_user_token" ],
    "/terms" => [ "Please check your personalisation carefully", "UK addresses only", "Consumer Rights Act 2015" ]
  }.each do |path, phrases|
    it "#{path} has its content" do
      get path

      expect(response).to have_http_status(:ok)
      phrases.each { |phrase| expect(page_text).to include(phrase) }
      expect(page_text).not_to include("%>")
    end
  end

  it "names the session cookie the app really uses" do
    get "/cookie-policy"

    expect(page_text).to include(Rails.application.config.session_options[:key])
  end

  it "highlights details still to be filled in" do
    get "/privacy-policy"

    markers = Nokogiri::HTML(response.body).css("mark.fill-in-later").map(&:text)
    expect(markers).to include("[to fill in: your full name]", "[to fill in: your business email address]")
  end

  it "links the checkout terms box to the terms and returns pages" do
    html = ApplicationController.render(partial: "checkouts/terms_and_conditions")

    expect(html).to include(%(href="#{terms_page_path}"), %(href="#{returns_page_path}"))
    expect(html).not_to include("Put your terms and conditions here")
  end
end
