# frozen_string_literal: true

# Customer personalisation (a name, date or message) on products.
#
# A product is personalisable when it has a product property named
# "personalisation" (set in the admin under Products > Product Properties).
# The property's value is the prompt shown to customers, e.g. "Name to add".
# The customer's text is stored on the cart line, Spree::LineItem#personalisation.
module Personalisation
  PROPERTY_NAME = "personalisation"
  MAX_LENGTH = 100

  module_function

  # The prompt to show for this product, or nil if it isn't personalisable.
  def prompt_for(product)
    product.property(PROPERTY_NAME).presence
  end

  def personalisable?(product)
    prompt_for(product).present?
  end

  # Collapse runs of whitespace (including newlines) and trim, so "  Freddie  "
  # and "Freddie" are the same personalisation.
  def normalise(text)
    text.to_s.squish.presence
  end

  # Added to Spree::LineItem.
  module LineItem
    extend ActiveSupport::Concern

    included do
      normalizes :personalisation, with: ->(text) { Personalisation.normalise(text) }
      validates :personalisation, length: { maximum: Personalisation::MAX_LENGTH }, allow_nil: true
    end
  end

  # Added to Spree::Order and registered as a line item comparison hook, so the
  # same product with different personalisation becomes separate cart lines.
  # `options` is the add-to-cart options (symbol keys) or, when merging a guest
  # cart into a user's cart, another line item's attributes (string keys).
  module Order
    def personalisation_matches?(line_item, options)
      options = options.to_h
      wanted = options[:personalisation] || options["personalisation"]
      line_item.personalisation == Personalisation.normalise(wanted)
    end
  end
end
