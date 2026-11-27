# frozen_string_literal: true

module PagesHelper
  # Details the legal/info pages still need (owner's name, contact email...).
  # They render as a highlighted "[to fill in: ...]" marker so nothing goes live
  # half-finished by accident. Fill them in by replacing the helper call in the
  # page template with the real text.
  def fill_in_later(description)
    tag.mark("[to fill in: #{description}]", class: "fill-in-later bg-yellow-200 text-black px-1 rounded-sm")
  end

  # The delivery options customers can choose at checkout, read live from the
  # admin (Settings > Shipping) so the delivery page never disagrees with checkout.
  # Returns [name, price] pairs; the price is nil when it's worked out per order.
  def delivery_options
    Spree::ShippingMethod.available_to_store(current_store)
      .where(available_to_users: true)
      .includes(:calculator).order(:id)
      .map do |method|
        calculator = method.calculator
        price = if calculator.is_a?(Spree::Calculator::Shipping::FlatRate)
          Spree::Money.new(calculator.preferred_amount, currency: calculator.preferred_currency.presence || Spree::Config.currency)
        end
        [ method.name, price ]
      end
  end
end
