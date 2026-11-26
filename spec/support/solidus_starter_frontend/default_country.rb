# frozen_string_literal: true

# The shop's default country is the UK (Spree::Config.default_country_iso = "GB").
# Production seeds every country, but the test database only has what factories
# create. Create the UK (as set up by db/seeds/uk_store.rb, with no county
# required) and the US (Solidus's address factory default) before each example,
# so shipping zones built from "all countries" cover both, as they would live.
RSpec.configure do |config|
  config.before do
    Spree::Country.find_by(iso: "GB") || FactoryBot.create(:country, iso: "GB", states_required: false)
    Spree::Country.find_by(iso: "US") || FactoryBot.create(:country, iso: "US")
  end
end
