module Bowser
  class Event
    def initialize native
      @native = native
    end

    def prevent
      `#@native.preventDefault()`
      self
    end

    def prevented?
      `#@native.defaultPrevented`
    end

    def meta?
      `#@native.metaKey`
    end

    def shift?
      `#@native.shiftKey`
    end

    def ctrl?
      `#@native.ctrlKey`
    end

    def alt?
      `#@native.altKey`
    end

    def button
      `#@native.button`
    end

    def target
      Element.new(`#@native.currentTarget`)
    end

    def code
      `#@native.keyCode`
    end
  end
end
