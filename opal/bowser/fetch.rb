require 'json'

module Bowser
  module Fetch
    class Response
      include DelegateNative

      def json
        ::Bowser::Promise.from_native(
          `#@native
            .json()
            .then(function(value) { return #{::Opal::JSON.from_object(`value`)} })`
        )
      end

      def text
        ::Bowser::Promise.from_native `#@native.text()`
      end
    end
  end
end

def fetch url, **options
  ::Bowser::Promise.from_native(`fetch(#{url}, #{options.to_n})
    .then(function(response) {
      return #{::Bowser::Fetch::Response.new(`response`);
    }})`)
end
