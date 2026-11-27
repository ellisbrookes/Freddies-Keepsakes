# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Admin theme", type: :system do
  let!(:store) { create(:store) }
  let!(:admin) { create(:admin_user, password: "secret123", password_confirmation: "secret123") }

  describe "admin login page" do
    it "uses the standalone centred layout instead of the admin chrome" do
      visit spree.admin_login_path

      expect(page).to have_css("body.admin-auth .admin-auth__card")
      expect(page).to have_css("h1", text: "Admin Login")
      expect(page).to have_css("link[href*='admin_auth']", visible: false)
      expect(page).to have_css("link[href*='spree/backend/themes/freddies']", visible: false)
      expect(page).not_to have_css(".solidus-admin--nav")
      expect(page).to have_link("Back to the shop", href: "/")
    end

    it "sends logged-out visitors of admin pages to it" do
      visit "/admin/orders"

      expect(page).to have_current_path(spree.admin_login_path)
      expect(page).to have_css(".admin-auth__card")
    end

    it "shows a bad login inside the card" do
      visit spree.admin_login_path
      fill_in "Email", with: admin.email
      fill_in "Password", with: "wrong"
      click_button "Login"

      expect(page).to have_css(".admin-auth__card .admin-auth__flash--error", text: "Invalid email or password.")
      expect(page).to have_css("h1", text: "Admin Login")
    end

    it "signs the admin in" do
      visit spree.admin_login_path
      fill_in "Email", with: admin.email
      fill_in "Password", with: "secret123"
      click_button "Login"

      expect(page).not_to have_css(".admin-auth__card")
      expect(page).not_to have_button("Login")
    end
  end

  describe "forgot password page" do
    it "uses the same card layout and confirms the reset request" do
      visit spree.admin_login_path
      click_link "Forgot Password?"

      expect(page).to have_css(".admin-auth__card h1", text: "Forgot Password?")
      fill_in "Email", with: admin.email
      click_button "Reset my password"

      expect(page).to have_text("you will receive an email with instructions")
    end
  end

  describe "signed-in admin pages" do
    before do
      visit spree.admin_login_path
      fill_in "Email", with: admin.email
      fill_in "Password", with: "secret123"
      click_button "Login"
    end

    it "loads the Freddies theme in the new admin" do
      visit "/admin/products"

      expect(page).to have_css("link[href*='solidus_admin/freddies']", visible: false)
      expect(page).to have_css("img[src*='logo_keepsakes_horizontal']")
    end

    it "loads the Freddies theme on legacy admin pages" do
      order = create(:order_ready_to_ship, line_items_count: 1)
      visit spree.edit_admin_order_path(order)

      expect(page).to have_css("link[href*='spree/backend/themes/freddies']", visible: false)
      expect(page).to have_css(".solidus-admin--nav img[src*='logo_keepsakes_horizontal']")
    end
  end
end
