# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Branded shop emails", type: :mailer do
  let(:store) { create(:store) }
  let(:order) { create(:order_with_line_items, store: store) }

  def html(mail) = mail.html_part.body.decoded
  def text(mail) = mail.text_part.body.decoded

  shared_examples "a branded email" do
    it "has the logo (with a full URL) and the shop links" do
      body = html(mail)
      logo = Nokogiri::HTML(body).at_css("img[alt='Freddies Personalised Boutique']")
      expect(logo["src"]).to match(%r{\Ahttp://example\.com/assets/logo-[0-9a-f]+\.png\z})
      expect(body).to include('href="http://example.com/store"', 'href="http://example.com/contact"')
      expect(text(mail)).to include("Shop: http://example.com/store")
    end

    it "is written in the shop's voice, not Solidus's defaults" do
      expect(html(mail)).to include("Hi there,")
      expect(html(mail)).not_to include("Dear Customer")
    end

    it "doesn't show product SKUs to customers" do
      sku = order.line_items.first.variant.sku
      expect(html(mail)).not_to include(sku)
      expect(text(mail)).not_to include(sku)
    end
  end

  describe "order confirmation" do
    let(:mail) { Spree::OrderMailer.confirm_email(order) }

    it_behaves_like "a branded email"

    it "shows the order number and total" do
      expect(html(mail)).to include(order.number, order.display_total.to_s)
    end
  end

  describe "order cancellation" do
    let(:mail) { Spree::OrderMailer.cancel_email(order) }

    it_behaves_like "a branded email"

    it "shows the personalisation of cancelled items" do
      order.line_items.first.update!(personalisation: "Freddie")
      expect(html(mail)).to include("Personalisation: “Freddie”")
    end
  end

  describe "order shipped" do
    let(:order) { create(:order_ready_to_ship, line_items_count: 1, store: store) }
    let(:carton) do
      order.line_items.first.update!(personalisation: "Freddie")
      order.shipments.first.ship!
      order.cartons.first.tap { |c| c.update!(tracking: "AB123456789GB") }
    end
    let(:mail) { Spree::CartonMailer.shipped_email(order: order, carton: carton) }

    it_behaves_like "a branded email"

    it "lists the parcel contents with personalisation and the tracking number" do
      expect(html(mail)).to include("Personalisation: “Freddie”", "Tracking number: AB123456789GB")
      expect(text(mail)).to include(%(Personalisation: "Freddie"), "Tracking number: AB123456789GB")
    end
  end
end
