require 'bowser/delegate_native'
require 'bowser/event_target'
require 'bowser/element'

module Bowser
  module Document
    extend DelegateNative
    extend EventTarget

    @native = `document`

    module_function

    # @return [Bowser::Element] the head element of the current document
    def head
      @head ||= Element.new(`#@native.head`)
    end

    # @return [Bowser::Element] the body element of the current document
    def body
      @body ||= Element.new(`#@native.body`)
    end

    # @return [Bowser::Element?] the first element that matches the given CSS
    #   selector or `nil` if no elements match
    def [] css
      native = `#@native.querySelector(css)`
      if `#{native} === null`
        nil
      else
        Element.new(native)
      end
    end

    # Create an element of the specified type
    #
    # @param type [String] the type of element to create
    # @example Bowser.document.create_element('div')
    def create_element type
      Element.new(`document.createElement(type)`)
    end
  end

  module_function

  # @return [Document] the browser's document object
  def document
    Document
  end
end
