require 'bowser/delegate_native'
require 'bowser/event_target'
require 'bowser/promise'

module Bowser
  module Window
    extend DelegateNative
    extend EventTarget

    @native = `window`

    module_function

    if `#@native.requestAnimationFrame !== undefined`
      # Add the given block to the current iteration of the event loop. If this
      # is called from another `animation_frame` call, the block is run in the
      # following iteration of the event loop.
      def animation_frame &block
        `requestAnimationFrame(function(now) { #{block.call `now`} })`
        self
      end
    else
      def animation_frame &block
        delay(0, &block)
        self
      end
    end

    def delay duration, &block
      Promise.new do |p|
        function = proc do
          begin
            yield if block_given?
            p.resolve
          rescue => e
            p.reject e
          end
        end

        `setTimeout(function() { #{block.call} }, duration * 1000)`
      end
    end
    alias set_timeout delay

    # Run the given block every `duration` seconds
    #
    # @param duration [Numeric] the number of seconds between runs
    def interval duration, &block
      `setInterval(function() { #{block.call} }, duration * 1000)`
      self
    end
    alias set_interval interval

    # @return [Location] the browser's Location object
    def location
      Location
    end

    # Scroll to the specified (x,y) coordinates
    def scroll x, y
      `window.scrollTo(x, y)`
    end

    # Wrapper for the browser's Location object
    module Location
      module_function

      # The "hash" of the current URL
      def hash
        `window.location.hash`
      end

      # Set the hash of the URL
      #
      # @param hash [String] the new value of the URL hash
      def hash= hash
        `window.location.hash = hash`
      end

      # The path of the current URL
      def path
        `window.location.pathname`
      end

      # The full current URL
      def href
        `window.location.href`
      end

      # Set the current URL
      #
      # @param href [String] the URL to navigate to
      def href= href
        `window.location.href = href`
      end
    end

    # The browser's history object
    module History
      module_function

      # @return [Boolean] true if the browser supports pushState, false otherwise
      def has_push_state?
        `!!window.history.pushState`
      end

      # Navigate to the specified path without triggering a full page reload
      #
      # @param path [String] the path to navigate to
      def push path
        `window.history.pushState({}, '', path)`
      end
    end

    # return [History] the browser's History object
    def history
      History
    end
  end

  module_function

  # return [Window] the browser's Window object
  def window
    Window
  end
end
