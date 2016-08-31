module Bowser
  module HTTP
    class FormData
      def initialize attributes={}
        @native = `new FormData()`
        attributes.each do |key, value|
          if `!!value.$$class` && value.respond_to?(:each)
            value.each do |item|
              append "#{key}[]", item
            end
          else
            append key, value
          end
        end
      end

      def append key, value
        data = if `!!value.native`
                 `value.native`
               else
                 value
               end

        `#@native.append(key, data)`
      end
    end
  end
end
