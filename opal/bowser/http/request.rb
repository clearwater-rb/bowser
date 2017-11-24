require 'bowser/http/response'
require 'bowser/event_target'

module Bowser
  module HTTP
    # A Ruby object representing an HTTP request to a remote server.
    class Request
      include EventTarget

      attr_reader :method, :url, :data, :headers, :promise
      attr_accessor :response

      UNSENT           = 0
      OPENED           = 1
      HEADERS_RECEIVED = 2
      LOADING          = 3
      DONE             = 4

      # @param method [String] the HTTP method to use
      # @param url [String] the URL to send the request to
      def initialize(method, url, native: `new XMLHttpRequest()`)
        @native = native
        @method = method
        @url = url
        @response = Response.new(@native)
      end

      # Send the HTTP request
      #
      # @keywordparam data [Hash, Bowser::HTTP::FormData, nil] the data to send
      #   with the request.
      # @keywordparam headers [Hash] the HTTP headers to attach to the request
      def send(data: {}, headers: {})
        `#@native.open(#{method}, #{url})`
        @data = data
        self.headers = headers

        if method == :get || method == :delete
          `#@native.send()`
        elsif Hash === data
          `#@native.send(#{JSON.generate data})`
        elsif `!!data['native']`
          `#@native.send(data['native'])`
        else
          `#@native.send(data)`
        end

        self
      end

      # Set the headers to the keys and values of the specified hash
      #
      # @param headers [Hash] the hash whose keys and values should be added as
      #   request headers
      def headers= headers
        @headers = headers
        headers.each do |attr, value|
          `#@native.setRequestHeader(attr, value)`
        end
      end

      # @return [Boolean] true if this request is a POST request, false otherwise
      def post?
        method == :post
      end

      # @return [Boolean] true if this request is a GET request, false otherwise
      def get?
        method == :get
      end

      # @return [Numeric] the numeric readyState of the underlying XMLHttpRequest
      def ready_state
        `#@native.readyState`
      end

      # @return [Boolean] true if this request has been sent, false otherwise
      def sent?
        ready_state >= OPENED
      end

      # @return [Boolean] true if we have received response headers, false otherwise
      def headers_received?
        ready_state >= HEADERS_RECEIVED
      end

      # @return [Boolean] true if we are currently downloading the response body, false otherwise
      def loading?
        ready_state == LOADING
      end

      # @return [Boolean] true if the response has been completed, false otherwise
      def done?
        ready_state >= DONE
      end

      def upload
        @upload ||= Upload.new(`#@native.upload`)
      end

      class Upload
        include EventTarget

        def initialize(native)
          @native = native
        end
      end
    end
  end
end
