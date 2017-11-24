require 'bowser/window'
require 'json'

module Bowser
  # A Ruby WebSocket class
  class WebSocket
    EVENT_NAMES = %w(
      open
      error
      message
      close
    )

    # param url [String] the URL to connect to
    # keywordparam native [JS] the native WebSocket connection
    def initialize url, native: `new WebSocket(url)`
      @url = url
      @native = native
      @handlers ||= Hash.new { |h, k| h[k] = [] }
      add_handlers

      on(:open) { @connected = true }
      on(:close) { @connected = false }
    end

    # Attach the given block as a handler for the specified event
    #
    # @param event_target [String] the name of the event to handle
    def on event_name, &block
      if EVENT_NAMES.include? event_name
        @handlers[event_name] << block
      else
        warn "[Bowser::WebSocket] #{event_name} is not one of the allowed WebSocket events: #{EVENT_NAMES.to_a}"
      end
    end

    # Send the given message across the connection
    #
    # @param msg [Hash, Array] the message to send. Should be a JSON-serializable structure.
    def send_message msg
      `#@native.send(#{JSON.dump(msg)})`
      self
    end

    # @return [Boolean] true if this socket is connected, false otherwise
    def connected?
      @connected
    end

    # Reconnect the websocket after a short delay if it is interrupted
    #
    # @keywordparam delay [Numeric] the number of seconds to wait before
    #   reconnecting. Defaults to 1 second.
    def autoreconnect!(delay: 1)
      return if @autoreconnect
      @autoreconnect = true

      on :close do
        Window.delay(delay) { initialize @url }
      end
    end

    # Close the current connection
    #
    # @param reason [String, nil] the reason this socket is being closed
    def close reason=`undefined`
      `#@native.close(reason)`
    end

    private

    def add_handlers
      EVENT_NAMES.each do |event_name|
        %x{
          #@native["on" + #{event_name}] = function(event) {
            var ruby_event;

            if(event.constructor === CloseEvent) {
              ruby_event = #{CloseEvent.new(`event`)};
            } else if(event.constructor === MessageEvent) {
              ruby_event = #{MessageEvent.new(`event`)};
            } else {
              ruby_event = #{Event.new(`event`)};
            }

            #{
              @handlers[event_name].each do |handler|
                handler.call `ruby_event`
              end
            }
          };
        }
      end
    end

    class CloseEvent
      attr_reader :code, :reason

      def initialize native
        @native = native
        @code = `#@native.code`
        @reason = `#@native.reason`
        @clean = `#@native.wasClean`
      end

      def clean?
        !!@clean
      end
    end

    class MessageEvent
      def initialize native
        @native = native
      end

      def text
        `#@native.data`
      end

      def data
        @data ||= get_data
      end

      def get_data(data=text)
        JSON.parse(data)
      end
    end
  end

  module_function

  # @param url [String] the URL to connect to
  # @return [Bowser::WebSocket] a websocket connection to the given URL
  def websocket *args
    WebSocket.new(*args)
  end
end
