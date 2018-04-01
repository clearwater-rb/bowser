require 'bowser/service_worker/response'
require 'bowser/service_worker/promise'

module Bowser
  module ServiceWorker
    class CacheStorage
      def initialize
        @native = `caches`
      end

      def match request, options={}
        Promise.from_native(`
          #@native.match(#{request.to_n}, #{options.to_n})
            .then(#{proc { |value| value && Response.from_native(value) }})
        `)
      end

      def has name
        Promise.from_native(`#@native.has(name)`)
      end

      def open name
        Promise.from_native(`
          #@native.open(name)
            .then(#{proc { |native| Cache.new(native) }})
            .catch(#{proc { |native| `console.error(native)` }})
        `)
      end

      class Cache
        def initialize native
          @native = native
        end

        def add_all requests
          Promise.from_native(`#@native.addAll(#{requests.map(&:to_n)})`)
        end

        def match request, **options
          Promise
            .from_native(`#@native.match(#{request.to_n}, #{options.to_n})`)
            .then do |response|
              if response
                Response.from_native response
              end
            end
        end

        def put request, response
          Promise.from_native(`#@native.put(#{request.to_n}, #{response.to_n})`)
        end

        def to_n
          @native
        end
      end
    end
  end
end
