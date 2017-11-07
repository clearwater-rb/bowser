require 'json'

module Bowser
  module HTTP
    class Response
      def initialize xhr
        @xhr = xhr
      end

      def code
        `#@xhr.status`
      end

      def body
        `#@xhr.response`
      end

      def json
        @json ||= JSON.parse(body) if `#{body} !== undefined`
      end

      def success?
        (200...400).cover? code
      end
      alias ok? success?

      def fail?
        !success?
      end
    end
  end
end
