# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "UK store seed" do
  def run_seed
    load Rails.root.join("db/seeds/uk_store.rb")
  end

  let!(:store) { create(:store, default_currency: nil) }

  it "sets the shop up to sell in the UK" do
    run_seed

    zone = Spree::Zone.find_by!(name: Spree::Config.checkout_zone)
    expect(zone.countries.pluck(:iso)).to eq([ "GB" ])
    expect(Spree::Country.find_by!(iso: "GB").states_required).to be(false)
    expect(store.reload.default_currency).to eq("GBP")

    methods = Spree::ShippingMethod.where(code: %w[uk_standard uk_tracked])
    expect(methods.count).to eq(2)
    expect(methods.map { |m| m.calculator.preferred_currency }.uniq).to eq([ "GBP" ])
    expect(methods.flat_map(&:zones).uniq).to eq([ zone ])
  end

  it "can be run again without duplicating or overwriting anything" do
    run_seed
    standard = Spree::ShippingMethod.find_by!(code: "uk_standard")
    standard.calculator.update!(preferred_amount: 2.50)

    run_seed

    expect(Spree::Zone.where(name: "UK").count).to eq(1)
    expect(Spree::ShippingMethod.where(code: "uk_standard").count).to eq(1)
    expect(standard.reload.calculator.preferred_amount).to eq(2.50)
  end
end
