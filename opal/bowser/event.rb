module Bowser
  # Wrapper for JS events
  class Event
    # @param [JS] the native event to wrap
    def initialize native
      @native = native
    end

    # Prevent the runtime from executing this event's default behavior. For
    # example, prevent navigation after clicking a link.
    #
    # @return [Bowser::Event] self
    def prevent
      `#@native.preventDefault()`
      self
    end

    # Prevent the runtime from bubbling this event up the hierarchy. This is
    # typically used to keep an event local to the element on which it was
    # triggered, such as keeping a click event on a button from unintentionally
    # triggering a handler on a parent element.
    #
    # @return self
    def stop_propagation
      `#@native.stopPropagation()`
      self
    end

    # @return [Boolean] true if `prevent` has been called on this event, false
    #   otherwise
    def prevented?
      `#@native.defaultPrevented`
    end

    # @return [Boolean] true if the Meta/Command/Windows key was pressed when
    #   this event fired, false otherwise
    def meta?
      `#@native.metaKey`
    end

    # @return [Boolean] true if the Shift key was pressed when this event fired,
    #   false otherwise
    def shift?
      `#@native.shiftKey`
    end

    # @return [Boolean] true if the Ctrl key was pressed when this event fired,
    #   false otherwise
    def ctrl?
      `#@native.ctrlKey`
    end

    # @return [Boolean] true if the Alt key was pressed when this event fired,
    #   false otherwise
    def alt?
      `#@native.altKey`
    end

    # The target for this event
    #
    # @return [Bowser::Element] the element on which this event was triggered
    # @todo Handle non-DOM events here
    def target
      Element.new(`#@native.target`)
    end

    # @return [Numeric] the key code associated with this event. Only useful for
    #   keyboard-based events.
    def code
      `#@native.keyCode`
    end

    # Return properties on the event not covered by Ruby methods.
    def method_missing name, *args
      property = name.gsub(/_[a-z]/) { |match| match[-1, 1].upcase }
      value = `#@native[property]`

      if `!!value && #{Proc === value}`
        value.call(*args)
      elsif `value == null`
        nil
      else
        value
      end
    end

    # @return [JS] the native event wrapped by this object.
    def to_n
      @native
    end
  end
end
