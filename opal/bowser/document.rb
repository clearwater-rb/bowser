require 'bowser/delegate_native'
require 'bowser/event_target'
require 'bowser/element'

module Bowser
  module Document
    extend DelegateNative
    extend EventTarget

    @native = `document`

    module_function

    def body
      @body ||= Element.new(`#@native.body`)
    end

    def [] css
      native = `#@native.querySelector(css)`
      if `#{native} === null`
        nil
      else
        Element.new(native)
      end
    end

    def create_element type
      Element.new(`document.createElement(type)`)
    end
  end

  module_function

  def document
    Document
  end
end
