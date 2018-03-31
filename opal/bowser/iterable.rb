module Bowser
  class Iterable
    include Enumerable

    def initialize js_iterable
      @js_iterable = js_iterable
    end

    def each
      `#@js_iterable.length`.times do |i|
        yield `#@js_iterable[i]`
      end
    end
  end
end
