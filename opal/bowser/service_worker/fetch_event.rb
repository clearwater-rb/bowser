require 'bowser/service_worker/request'
require 'bowser/service_worker/extendable_event'

module Bowser
  module ServiceWorker
    class FetchEvent < ExtendableEvent
      def url
        `#@native.request.url`
      end

      def reload?
        `#@native.isReload`
      end

      def client_id
        `#@native.clientId`
      end

      def request
        @request ||= Request.from_native(`#@native.request`)
      end

      def respond_with promise
        `#@native.respondWith(#{promise.then(&:to_n).to_n})`
      end
    end
  end
end
