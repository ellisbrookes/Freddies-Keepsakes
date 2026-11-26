# frozen_string_literal: true

# Sets the shop up to sell in the UK: pounds, a UK delivery zone and delivery
# options. Safe to run more than once: it only creates what's missing and never
# changes delivery prices that have been edited in the admin.

uk = Spree::Country.find_by!(iso: "GB")
uk.update!(states_required: false)

Spree::Store.find_each { |store| store.update!(default_currency: "GBP") if store.default_currency.blank? }

zone = Spree::Zone.find_or_create_by!(name: "UK") { |z| z.description = "United Kingdom" }
zone.members.find_or_create_by!(zoneable: uk)

category = Spree::ShippingCategory.find_or_create_by!(name: "Default")

# Placeholder services and prices: change them in the admin under Settings > Shipping.
[
  { name: "Standard delivery (2–4 working days)", code: "uk_standard", amount: 3.99 },
  { name: "Tracked delivery (1–2 working days)", code: "uk_tracked", amount: 5.99 }
].each do |attrs|
  next if Spree::ShippingMethod.exists?(code: attrs[:code])

  Spree::ShippingMethod.create!(
    name: attrs[:name],
    code: attrs[:code],
    zones: [ zone ],
    shipping_categories: [ category ],
    calculator: Spree::Calculator::Shipping::FlatRate.new(preferred_amount: attrs[:amount], preferred_currency: "GBP")
  )
end

# Solidus's default seeds create a stock location with no address; place it in the UK.
Spree::StockLocation.where(country_id: nil).find_each { |location| location.update!(country: uk) }
