require 'bowser/service_worker/promise'

module Bowser
  module ServiceWorker
    class Clients
      def initialize native
        @native = native
      end

      def claim
        Promise.from_native(`#@native.claim()`)
      end

      def to_n
        @native
      end
    end
  end
end
