# frozen_string_literal: true

# Workaround for Capybara 3.40 + recent Chrome.
#
# If a finder or matcher runs while the browser is swapping in a new page,
# Chrome can answer with a generic error:
#   unknown error: unhandled inspector error:
#   {"code":-32000,"message":"Node with given id does not belong to the document"}
# This is the same situation as a stale element, but Capybara only retries
# errors by class, and this arrives as Selenium's catch-all UnknownError. So it
# fails the spec at once instead of being retried until the new page is ready.
#
# Treat that one message like a stale element. Everything else is unchanged.
module CapybaraDetachedNodeRetry
  DETACHED_NODE_MESSAGE = "does not belong to the document"

  protected

  def catch_error?(error, errors = nil)
    return true if error.is_a?(Selenium::WebDriver::Error::UnknownError) &&
      error.message.include?(DETACHED_NODE_MESSAGE)

    super
  end
end

Capybara::Node::Base.prepend(CapybaraDetachedNodeRetry)
