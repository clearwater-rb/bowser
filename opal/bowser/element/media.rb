require 'bowser/element'

module Bowser
  class Element
    element :video, :audio do
      def buffered
        TimeRanges.new(`#@native.buffered`)
      end

      def played
        TimeRanges.new(`#@native.played`)
      end

      def seekable
        TimeRanges.new(`#@native.seekable`)
      end

      def network_state
        case `#@native.networkState`
        when `HTMLMediaElement.NETWORK_EMPTY` then :no_data
        when `HTMLMediaElement.NETWORK_IDLE` then :idle
        when `HTMLMediaElement.NETWORK_LOADING` then :loading
        when `HTMLMediaElement.NETWORK_NO_SOURCE` then :no_source
        end
      end
    end

    element :video do
      def fullscreen
        fullscreen = %w(
          requestFullScreen
          requestFullscreen
          webkitRequestFullScreen
          webkitRequestFullscreen
          mozRequestFullScreen
          msRequestFullscreen
        ).find { |prop| `!!#@native[prop]` }

        if fullscreen
          `#@native[fullscreen]()`
        else
          warn "[#{self.class}] Cannot determine the method to full-screen a video"
          super
        end
      end
      alias request_fullscreen fullscreen
    end

    class TimeRanges
      include Enumerable

      def initialize native
        @native = native
      end

      def to_n
        @native
      end

      def each
        `#@native.length`.times do |i|
          yield TimeRange.new(`#@native.start(i)`, `#@native.end(i)`)
        end

        self
      end
    end

    class TimeRange
      attr_reader :start, :end

      def initialize start, _end
        @start = start
        @end = _end
      end

      alias begin start
    end
  end
end
