# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Mobile layout", :js, type: :system do
  # Resize explicitly: Chrome is reused between specs, so the screen_size
  # metadata only applies when it happens to start the browser.
  before do
    create(:store)
    page.driver.browser.manage.window.resize_to(320, 800)
  end

  after { page.driver.browser.manage.window.resize_to(1800, 1400) }

  it "is really testing a phone-sized window" do
    visit root_path
    expect(page.evaluate_script("window.innerWidth")).to eq(320)
  end

  it "keeps the header logo clear of the menu button and the basket/account icons" do
    visit root_path

    edges = page.evaluate_script(<<~JS)
      (() => {
        const box = el => el.getBoundingClientRect();
        return {
          menu: box(document.querySelector("header button[aria-controls='navbar-default']")).right,
          logoLeft: box(document.querySelector("header a[title]")).left,
          logoRight: box(document.querySelector("header a[title]")).right,
          icons: box(document.querySelector("[data-controller='top-bar'] > div")).left
        };
      })()
    JS

    expect(edges["logoLeft"]).to be >= edges["menu"]
    expect(edges["logoRight"]).to be <= edges["icons"]
  end

  it "shows the main site links in the menu drawer" do
    visit root_path
    # The open button sits in the header bar; its twin inside the drawer closes it.
    find("header button[aria-controls='navbar-default']:not([data-drawer-target='drawer'] *)").click

    within("[data-drawer-target='drawer']") do
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Sign in", href: login_path)
      expect(page).to have_link("Basket", href: cart_path)
      expect(page).to have_link("Contact us", href: contact_page_path)
    end
  end
end

RSpec.describe "Choosing a product option", :js, type: :system do
  let(:option_type) { create(:option_type, name: "size", presentation: "Size") }
  let(:small) { create(:option_value, option_type: option_type, name: "s", presentation: "S") }
  let(:medium) { create(:option_value, option_type: option_type, name: "m", presentation: "M") }
  let(:product) { create(:product, option_types: [ option_type ]) }

  before do
    create(:store)
    create(:variant, product: product, option_values: [ small ])
    create(:variant, product: product, option_values: [ medium ])
  end

  it "selects the option without a JavaScript error" do
    visit product_path(product)
    page.execute_script(<<~JS)
      window.__pageErrors = [];
      window.addEventListener("error", (event) => window.__pageErrors.push(event.message));
    JS

    find("label.selection-items", text: "M").click

    expect(page).to have_css("#selected-size", text: "M")
    expect(page.evaluate_script("window.__pageErrors")).to eq([])
  end
end
