require 'bowser/service_worker/extendable_event'
require 'native' # for Hash.new(js_obj)

module Bowser
  module ServiceWorker
    class PushEvent < ExtendableEvent
      def data
        PushMessageData.new(`#@native.data`)
      end

      class PushMessageData
        def initialize data
          @data = data
        end

        def json
          Hash.new(`#@data.json()`)
        end

        def text
          `#@data.text()`
        end
      end
    end
  end
end
