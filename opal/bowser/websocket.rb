require 'bowser/window'
require 'json'

module Bowser
  class WebSocket
    EVENT_NAMES = %w(
      open
      error
      message
      close
    )

    def initialize url
      @url = url
      @native = `new WebSocket(url)`
      @handlers ||= Hash.new { |h, k| h[k] = [] }
      add_handlers
    end

    def on event_name, &block
      if EVENT_NAMES.include? event_name
        @handlers[event_name] << block
      else
        warn "[Bowser::WebSocket] #{event_name} is not one of the allowed WebSocket events: #{EVENT_NAMES.to_a}"
      end
    end

    def send_message msg
      `#@native.send(#{JSON.dump(msg)})`
      self
    end

    # Reconnect the websocket after a short delay if it is interrupted
    def autoreconnect!(delay: 1)
      return if @autoreconnect
      @autoreconnect = true

      on :close do
        Window.delay(delay) { initialize @url }
      end
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

  def websocket *args
    WebSocket.new(*args)
  end
end
