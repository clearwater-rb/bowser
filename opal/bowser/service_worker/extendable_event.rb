require 'bowser/service_worker/promise'

module Bowser
  module ServiceWorker
    class ExtendableEvent
      def initialize native
        @native = native
      end

      def wait_until promise
        Promise.from_native `#@native.waitUntil(#{promise.to_n})`
      end

      def to_n
        @native
      end
    end
  end
end
