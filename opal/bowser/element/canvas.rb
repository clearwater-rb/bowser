require 'bowser/element'

module Bowser
  class Element
    element :canvas do
      def context(type='2d')
        Context.new(`#@native.getContext(#{type})`)
      end

      class Context
        include DelegateNative

        def initialize native
          @native = native
        end
      end
    end
  end
end
