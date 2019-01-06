module Bowser
  class Promise
    attr_reader :value

    if RUBY_ENGINE == 'opal'
      def self.from_native promise
        new do |p|
          %x{
            #{promise}.then(
              function(value) { #{p.resolve(`value`)} },
              function(reason) { #{p.reject(`reason`)} }
            )
          }
        end
      end
    end

    def self.race promises
      new do |promise|
        promises.each do |p|
          p.then { |value| promise.resolve value }
          p.catch { |reason| promise.reject reason }
        end
      end
    end

    def self.all promises
      new do |promise|
        promises.each do |p|
          p.then do |value|
            promise.resolve promises.map(&:value) if promises.all?(&:resolved?)
          end

          p.catch { |reason| promise.reject reason }
        end
      end
    end

    def self.resolve value=nil
      new { |p| p.resolve value }
    end

    def self.reject value
      new { |p| p.reject value }
    end

    def initialize
      @callbacks = []

      yield self if block_given?

      @then = method(:then).to_proc
      @catch = method(:catch).to_proc
    end

    def then handler=nil, &block
      self.class.new do |p|
        callback = SuccessCallback.new(p, handler || block)

        if pending?
          @callbacks << callback
        elsif resolved?
          callback.resolve value
        elsif rejected?
          callback.reject value
        end
      end
    end

    def catch handler=nil, &block
      self.class.new do |p|
        callback = FailureCallback.new(p, handler || block)

        if pending?
          @callbacks << callback
        elsif resolved?
          callback.resolve value
        elsif rejected?
          callback.reject value
        end
      end
    end

    def resolve value=nil
      return if settled?

      case value
      when NativeValue
        resolve_value value
      when self
        reject TypeError.new('Cannot resolve a promise with itself')
      when Promise
        value
          .then { |v| resolve v }
          .catch { |v| reject v }
      else
        resolve_value value
      end
    end

    def resolve_value value
      @value = value
      @state = :resolved
      @callbacks.each { |callback| callback.resolve value }
      @callbacks.clear
    end

    def reject reason
      return if settled?

      case value
      when Promise
        value.catch { |v| reject v }
      else
        @value = reason
        @state = :rejected
        @callbacks.each do |callback|
          callback.reject reason
        end
        @callbacks.clear
      end
    end

    def resolved?
      @state == :resolved
    end

    def rejected?
      @state == :rejected
    end

    def pending?
      !settled?
    end

    def settled?
      rejected? || resolved?
    end

    class Callback
      def initialize promise, block
        @promise = promise
        @block = block || proc { |value| value }
      end
    end

    class SuccessCallback < Callback
      def resolve value
        @promise.resolve @block.call(value)
      rescue => e
        reject e
      end

      def reject value
        @promise.reject value
      end
    end

    class FailureCallback < Callback
      def resolve value
        @promise.resolve value
      end

      def reject value
        @promise.resolve @block.call(value)
      rescue => e
        @promise.reject e
      end
    end

    NativeValue = Object.new.tap do |native|
      # Determines whether something is a native JS value. Returns false if
      # we're not running on a JS VM. Otherwise, it returns whether the value
      # is a JS primitive (string, number, undefined, null) or a native JS
      # object.
      def native.=== value
        RUBY_ENGINE == 'opal' &&
          `value == null || value.$$is_string || value.$$is_number || value.$$is_boolean || !('$$class' in value)`
      end
    end
  end
end
