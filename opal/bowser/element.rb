require 'bowser/event_target'
require 'bowser/file_list'

module Bowser
  class Element
    include EventTarget

    def initialize native
      @native = native
    end

    def inner_dom= node
      clear
      append node
    end

    def inner_html
      `#@native.innerHTML`
    end

    def inner_html= html
      `#@native.innerHTML = html`
    end

    def children
      elements = []

      %x{
        var children = #@native.children;
        for(var i = 0; i < children.length; i++) {
          elements[i] = #{Element.new(`children[i]`)};
        }
      }

      elements
    end

    def empty?
      `#@native.children.length === 0`
    end

    def clear
      if %w(input textarea).include? type
        `#@native.value = null`
      else
        children.each do |child|
          remove_child child
        end
      end

      self
    end

    def remove_child child
      `#@native.removeChild(child.native ? child.native : child)`
    end

    def type
      `#@native.nodeName`.downcase
    end

    def append node
      `#@native.appendChild(node.native ? node.native : node)`
      self
    end

    # Form input methods
    def checked?
      `!!#@native.checked`
    end

    # Convenience for when you only need a single file
    def file
      files.first
    end

    def files
      FileList.new(`#@native.files`)
    end

    # Fall back to native properties.
    def method_missing message, *args, &block
      camel_cased_message = message
        .gsub(/_\w/) { |match| match[1].upcase }
        .sub(/=$/, '')

      # translate setting a property
      if message.end_with? '='
        return `#@native[camel_cased_message] = args[0]`
      end

      # translate `supported?` to `supported` or `isSupported`
      if message.end_with? '?'
        camel_cased_message = camel_cased_message.chop
        property_type = `typeof(#@native[camel_cased_message])`
        if property_type == 'undefined'
          camel_cased_message = "is#{camel_cased_message[0].upcase}#{camel_cased_message[1..-1]}"
        end
      end

      # If the native element doesn't have this property, bubble it up
      super if `typeof(#@native[camel_cased_message]) === 'undefined'`

      property = `#@native[camel_cased_message]`

      if `property === false`
        return false
      else
        property = `property || nil`
      end

      # If it's a method, call it. Otherwise, return it.
      if `typeof(property) === 'function'`
        `property.apply(#@native, args)`
      else
        property
      end
    end

    def ==(other)
      `#@native === #{other.to_n}`
    end

    def to_n
      @native
    end
  end
end
