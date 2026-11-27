# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Personalised products", type: :system do
  include SolidusStarterFrontend::System::CheckoutHelpers
  include_context "checkout setup"

  before { mug.set_property("personalisation", "Name to add") }

  it "carries the customer's personalisation from the product page to the order" do
    visit product_path(mug)
    expect(page).to have_field("Name to add:")

    fill_in "Name to add:", with: "Freddie"
    add_to_cart
    within(".cart-item") { expect(page).to have_content("Personalisation: “Freddie”") }

    checkout_as_guest
    {
      name: "Jess Smith", address1: "1 High Street", city: "Leeds",
      zipcode: "LS1 1AA", phone: "0113 496 0000"
    }.each { |field, value| fill_in "order_bill_address_attributes_#{field}", with: value }
    check "order_use_billing"
    save_and_continue
    expect(page).to have_content("Personalisation: “Freddie”")

    save_and_continue
    save_and_continue
    check "Agree to Terms of Service"
    click_and_wait_for_page_load "Place Order"

    expect(page).to have_content(I18n.t("spree.order_processed_successfully"))
    expect(page).to have_content("Personalisation: “Freddie”")
    expect(Spree::Order.complete.last.line_items.map(&:personalisation)).to eq([ "Freddie" ])
  end

  it "doesn't show the personalisation field on other products" do
    plain = create(:product, name: "Plain tote")
    visit product_path(plain)

    expect(page).to have_button("add-to-cart-button")
    expect(page).not_to have_field("personalisation")
  end

  it "shows the personalisation, escaped, on the admin order page" do
    order = create(:order_ready_to_ship, line_items_count: 1)
    order.line_items.first.update!(personalisation: "<b>Freddie</b>")
    admin = create(:admin_user, password: "secret123", password_confirmation: "secret123")

    visit login_path
    fill_in "Email:", with: admin.email
    fill_in "Password:", with: "secret123"
    click_and_wait_for_page_load "Login"
    visit spree.edit_admin_order_path(order)

    expect(page).to have_content("Personalisation: “<b>Freddie</b>”")
    expect(page).not_to have_css("b", text: "Freddie")
  end
end
