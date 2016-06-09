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

    def clear
      %x{
        var native = #@native;

        if(native.nodeName === 'INPUT' || native.nodeName === 'TEXTAREA') {
          native.value = null;
        } else {
          var children = native.children;
          for(var i = 0; i < children.length; i++) {
            children[i].remove();
          }
        }
      }
      self
    end

    def append node
      `#@native.appendChild(node)`
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

      property = `#@native[camel_cased_message] || nil`

      # If it's a method, call it. Otherwise, return it.
      if `typeof(property) === 'function'`
        `property.apply(#@native, args)`
      else
        property
      end
    end
  end
end
