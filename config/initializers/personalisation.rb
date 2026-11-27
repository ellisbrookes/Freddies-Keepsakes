# frozen_string_literal: true

# Wires customer personalisation (see app/models/personalisation.rb) into Solidus.
Rails.application.config.to_prepare do
  Spree::LineItem.include(Personalisation::LineItem) unless Spree::LineItem < Personalisation::LineItem
  Spree::Order.include(Personalisation::Order) unless Spree::Order < Personalisation::Order

  # Let the personalisation through when a product is added to the cart.
  unless Spree::PermittedAttributes.line_item_attributes.include?(:personalisation)
    Spree::PermittedAttributes.line_item_attributes << :personalisation
  end

  hooks = Spree::Config.line_item_comparison_hooks
  hooks << :personalisation_matches? unless hooks.include?(:personalisation_matches?)
end
