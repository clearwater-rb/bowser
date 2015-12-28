require 'bowser/event_target'

module Bowser
  module Window
    extend EventTarget

    @native = `window`

    module_function

    if `#@native.requestAnimationFrame !== undefined`
      def animation_frame &block
        `requestAnimationFrame(block)`
        self
      end
    else
      def animation_frame &block
        delay(0.16, &block)
        self
      end
    end

    def delay duration, &block
      `setTimeout(block, duration * 1000)`
      self
    end

    def interval duration, &block
      `setInterval(block, duration * 1000)`
      self
    end

    def location
      Location
    end

    def scroll x, y
      `window.scrollTo(x, y)`
    end

    module Location
      module_function

      def path
        `window.location.pathname`
      end
    end

    module History
      module_function

      def push path
        `window.history.pushState({}, '', path)`
      end
    end

    def history
      History
    end
  end

  module_function

  def window
    Window
  end
end
