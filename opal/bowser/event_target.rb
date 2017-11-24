require 'bowser/event'

module Bowser
  module EventTarget
    # Add the block as a handler for the specified event name. Will use either
    # `addEventListener` or `addListener` if they exist.
    #
    # @param event_name [String] the name of the event
    # @return [Proc] the block to pass to `off` to remove this handler
    # @yieldparam event [Bowser::Event] the event object
    def on event_name, &block
      wrapper = proc { |event| block.call Event.new(event) }

      if `#@native.addEventListener !== undefined`
        `#@native.addEventListener(event_name, wrapper)`
      elsif `#@native.addListener !== undefined`
        `#@native.addListener(event_name, wrapper)`
      else
        warn "[Bowser] Not entirely sure how to add an event listener to #{self}"
      end

      wrapper
    end

    # Remove an event handler
    #
    # @param event_name [String] the name of the event
    # @block the handler to remove, as returned from `on`
    def off event_name, &block
      if `#@native.removeEventListener !== undefined`
        `#@native.removeEventListener(event_name, block)`
      elsif `#@native.removeListener !== undefined`
        `#@native.removeListener(event_name, block)`
      else
        warn "[Bowser] Not entirely sure how to remove an event listener from #{self}"
      end

      nil
    end
  end
end
