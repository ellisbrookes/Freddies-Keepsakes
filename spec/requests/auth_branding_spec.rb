# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Branded sign-in pages", type: :request do
  let!(:store) { create(:store) }

  # The footer also shows the logo, so look for it inside the form's own <article>.
  def logo_in(article_id)
    Nokogiri::HTML(response.body).at_css("article##{article_id} img[src*='/assets/logo-']")
  end

  {
    "sign in" => [ "/login", "existing-customer" ],
    "sign up" => [ "/signup", "new-customer" ],
    "forgot password" => [ "/password/recover", "forgot-password" ],
    "reset password" => [ "/password/change?reset_password_token=abc", "change-password" ]
  }.each do |page_name, (path, article_id)|
    it "shows the logo on the #{page_name} page" do
      get path

      expect(response).to have_http_status(:ok)
      logo = logo_in(article_id)
      expect(logo).to be_present
      expect(logo["alt"]).to eq(store.name)
    end
  end

  it "keeps the plain layout for the sign-in form inside checkout" do
    variant = create(:product).master
    post cart_line_items_path, params: { variant_id: variant.id, quantity: 1 }

    get new_checkout_session_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('id="existing-customer"')
    expect(logo_in("existing-customer")).to be_nil
  end
end
