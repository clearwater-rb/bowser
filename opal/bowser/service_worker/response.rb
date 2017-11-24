module Bowser
  module ServiceWorker
    class Response
      def self.from_native native
        new(native) if `#{native} != null`
      end

      def initialize native
        @native = native
      end

      def json
        @json ||= `#@native.json()`
      end

      def text
        @text ||= `#@native.text()`
      end

      def to_n
        @native
      end

      def url
        `#@native.url`
      end

      def status
        `#@native.status`
      end

      def inspect
        "#<#{self.class.name}:0x#{(object_id * 2).to_s(16)} @url=#{url.inspect} @status=#{status.inspect}>"
      end

      def to_s
        inspect
      end
    end
  end
end
