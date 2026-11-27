# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Personalising a product", type: :request, with_signed_in_user: true do
  let!(:store) { create(:store) }
  let(:user) { create(:user) }
  let(:product) { create(:product).tap { |p| p.set_property("personalisation", "Name to add") } }
  let(:variant) { product.master }

  def add(personalisation: nil, quantity: 1, variant_id: variant.id)
    params = { variant_id: variant_id, quantity: quantity }
    params[:personalisation] = personalisation unless personalisation.nil?
    post cart_line_items_path, params: params
  end

  def lines
    user.orders.first&.line_items.to_a
  end

  it "stores the personalisation on the cart line, tidied up" do
    add(personalisation: "  Freddie\n  Smith ")

    expect(response).to redirect_to(cart_path)
    expect(lines.map(&:personalisation)).to eq([ "Freddie Smith" ])
  end

  it "shows it in the cart without leaking template code" do
    add(personalisation: "Freddie")
    get cart_path

    text = Nokogiri::HTML(response.body).at_css(".cart-item").text.squish
    expect(text).to include("Personalisation: “Freddie”")
    expect(text).not_to include("%>")
  end

  it "keeps different personalisations of the same product as separate lines" do
    add(personalisation: "Freddie")
    add(personalisation: "Jess")

    expect(lines.map(&:personalisation)).to contain_exactly("Freddie", "Jess")
    expect(lines.map(&:quantity)).to eq([ 1, 1 ])
  end

  it "adds to the existing line when the personalisation is the same" do
    add(personalisation: "Freddie")
    add(personalisation: " Freddie ")

    expect(lines.size).to eq(1)
    expect(lines.first.quantity).to eq(2)
  end

  it "asks for the personalisation when it's left blank" do
    add(personalisation: "   ")

    expect(lines).to be_empty
    expect(flash[:error]).to eq("Please fill in your personalisation (Name to add)")
  end

  it "rejects personalisation over the length limit" do
    add(personalisation: "x" * (Personalisation::MAX_LENGTH + 1))

    expect(lines.to_a).to be_empty
    expect(flash[:error]).to include("Personalisation is too long")
  end

  it "ignores personalisation for products that aren't personalisable" do
    plain = create(:product)
    add(personalisation: "Freddie", variant_id: plain.master.id)

    expect(response).to redirect_to(cart_path)
    expect(lines.map(&:personalisation)).to eq([ nil ])
  end

  it "keeps separate personalised lines when a guest cart is merged into the user's cart" do
    order = create(:order, user: user, store: store)
    order.contents.add(variant, 1, personalisation: "Freddie")
    guest = create(:order, store: store)
    guest.contents.add(variant, 1, personalisation: "Jess")

    Spree::OrderMerger.new(order).merge!(guest, user)

    expect(order.reload.line_items.map(&:personalisation)).to contain_exactly("Freddie", "Jess")
  end
end
