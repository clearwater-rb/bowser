module Bowser
  module DelegateNative
    # Fall back to native properties. If the message sent to this element is not
    # recognized, it checks to see if it is a property of the native element. It
    # also checks for variations of the message name, such as:
    #
    #   :supported? => [:supported, :isSupported]
    #
    # If a property with the specified message name is found and it is a
    # function, that function is invoked with `args`. Otherwise, the property
    # is returned as is.
    def method_missing message, *args, &block
      property_name = property_for_message(message)
      property = `#@native[#{property_name}]`

      # translate setting a property
      if message.end_with? '='
        return `#@native[#{property_name}] = args[0]`
      end

      # If the native element doesn't have this property, bubble it up
      super if `#{property} === undefined`

      if `property === false`
        return false
      else
        property = `property == null ? nil : property`
      end

      # If it's a method, call it. Otherwise, return it.
      if `typeof(property) === 'function'`
        `property.apply(#@native, args)`
      else
        property
      end
    end

    def respond_to_missing? message, include_all
      return true if message.end_with? '='
      return true if property_for_message(message)

      false
    end

    def property_for_message message
      camel_cased_message = message
        .gsub(/_\w/) { |match| `match[1]`.upcase }
        .sub(/=$/, '')

      # translate `supported?` to `supported` or `isSupported`
      if message.end_with? '?'
        camel_cased_message = camel_cased_message.chop
        property_type = `typeof(#@native[camel_cased_message])`
        if property_type == 'undefined'
          camel_cased_message = "is#{camel_cased_message[0].upcase}#{camel_cased_message[1..-1]}"
        end
      end

      camel_cased_message
    end
  end
end
