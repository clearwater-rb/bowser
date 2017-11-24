module Bowser
  module ServiceWorker
    class ExtendableEvent
      def initialize native
        @native = native
      end

      def wait_until promise
        `#@native.waitUntil(#{promise.to_n})`

        promise
      end

      def to_n
        @native
      end
    end
  end
end
