module Bowser
  module ServiceWorker
    class Promise
      attr_reader :value, :failure

      def initialize &block
        @native = `new Promise(function(resolve, reject) {
          #{@resolve = `resolve`};
          #{@reject = `reject`};
          #{block.call(self) if block_given?};
        })`
      end

      def self.from_native promise
        p = allocate
        p.instance_exec { @native = promise }
        p
      end

      def self.all promises
        from_native `Promise.all(#{promises.map(&:to_n)})`
      end

      def self.race promises
        from_native `Promise.race(#{promises.map(&:to_n)})`
      end

      def self.reject reason
        new.reject reason
      end

      def self.resolve value
        new.resolve value
      end

      def then &block
        Promise.from_native `#@native.then(block)`
      end

      def fail &block
        Promise.from_native `#@native.catch(block)`
      end

      def always &block
        Promise.from_native `#@native.then(block).fail(block)`
      end

      def resolve value
        return self if resolved?
        if rejected?
          `console.warn(#{self}, #{"tried to resolve, already #{resolved? ? 'resolved' : 'rejected'} with"}, #{@value || @failure})`
        end

        @value = value
        @resolve.call value
        self
      end

      def reject failure
        return self if rejected?
        if resolved?
          `console.warn(#{self}, #{"tried to reject, already #{resolved? ? 'resolved' : 'rejected'} with"}, #{@value || @failure})`
        end

        @failure = failure
        @reject.call failure
        self
      end

      def realized?
        resolved? || rejected?
      end

      def resolved?
        !value.nil?
      end

      def rejected?
        !failure.nil?
      end

      def to_n
        @native
      end

      %x{
        Opal.defn(self, 'then', function(callback) {
          var self = this;

          #{self.then(&`callback`)};
        });

        Opal.defn(self, 'catch', function(callback) {
          var self = this;

          #{self.fail(&`callback`)};
        });
      }
    end
  end
end
