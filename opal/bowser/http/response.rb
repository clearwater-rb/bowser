require 'json'

module Bowser
  module HTTP
    # Ruby class representing an HTTP response from a remote server
    class Response
      # @param xhr [JS] a native XMLHttpRequest object
      def initialize xhr
        @xhr = xhr
      end

      # @return [Numeric] the HTTP status code of the response
      def code
        `#@xhr.status`
      end

      # @return [String] the body of the response as a string
      def body
        `#@xhr.response`
      end

      # @return [Hash, Array, String] the response body deserialized from JSON
      def json
        @json ||= JSON.parse(body) if `#{body} !== undefined`
      end

      # @return [Boolean] true if this was a successful response (2xx-3xx), false otherwise
      def success?
        (200...400).cover? code
      end
      alias ok? success?

      # @return [Boolean] true if this represents a failed response (4xx-5xx)
      def fail?
        !success?
      end
    end
  end
end
