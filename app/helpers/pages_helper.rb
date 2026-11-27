# frozen_string_literal: true

module PagesHelper
  # Details the legal/info pages still need (owner's name, contact email...).
  # They render as a highlighted "[to fill in: ...]" marker so nothing goes live
  # half-finished by accident. Fill them in by replacing the helper call in the
  # page template with the real text.
  def fill_in_later(description)
    tag.mark("[to fill in: #{description}]", class: "fill-in-later bg-yellow-200 text-black px-1 rounded-sm")
  end
end
