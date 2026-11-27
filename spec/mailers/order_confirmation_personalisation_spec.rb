# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Order confirmation email personalisation", type: :mailer do
  let(:store) { create(:store) }
  let(:order) { create(:order_with_line_items, store: store) }
  let(:line_item) { order.line_items.first }

  def parts
    mail = Spree::OrderMailer.confirm_email(order)
    { html: mail.html_part.body.decoded, text: mail.text_part.body.decoded }
  end

  it "includes the customer's personalisation under the item" do
    line_item.update!(personalisation: "Nan's mug & cake")

    email = parts
    expect(email[:html]).to include("Personalisation: “Nan&#39;s mug &amp; cake”")
    expect(email[:text]).to include(%(Personalisation: "Nan's mug & cake"))
  end

  it "escapes it in the HTML email" do
    line_item.update!(personalisation: "<script>alert('hi')</script>")

    email = parts
    expect(email[:html]).not_to include("<script>")
    expect(email[:html]).to include("&lt;script&gt;")
  end

  it "says nothing about personalisation for ordinary items" do
    email = parts
    expect(email[:html]).not_to include("Personalisation")
    expect(email[:text]).not_to include("Personalisation")
  end
end
