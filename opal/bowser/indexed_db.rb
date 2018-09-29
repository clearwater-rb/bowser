require 'bowser/event_target'
require 'bowser/promise'

module Bowser
  class IndexedDB
    name = %w(
      indexedDB
      mozIndexedDB
      webkitIndexedDB
      msIndexedDB
    ).find { |name| `!!window[#{name}]` }
    NATIVE = `window[#{name}]`

    def initialize name, version: 1
      @thens = []

      request = Request.new(`#{NATIVE}.open(#{name}, #{version})`)
      request.on :error do |event|
        `console.error(event)`
      end
      request.on :success do |event|
        @native = event.target.result
        @open = true

        @thens.each(&:call)
        @thens = []
      end

      request.on :upgradeneeded do |event|
        @native = event.target.result

        if block_given?
          yield self
        else
          raise ArgumentError, "You must provide a block to `#{self.class}.new` in order to set up the database if the user's browser does not have it."
        end
      end
    end

    def create_object_store name, key_path: `undefined`, unique: false
      ObjectStore.new(`#@native.createObjectStore(#{name}, { keyPath: #{key_path} })`)
    end

    def delete_object_store name
      `#@native.deleteObjectStore(#{name})`
    rescue `TypeError` => e
      # If the object store doesn't exist, we do nothing. The store not existing
      # is the end state we want after this method call anyway.
    end

    def [] store
      transaction(store).object_store(store)
    end

    def put **things # TODO: Come up with a less terrible name
      things.each do |store_name, records|
        transaction(store_name, :readwrite)
          .object_store(store_name)
          .tap do |store|
            records.each do |record|
              store.put record
            end
          end
      end
    end

    def transaction name, mode=:readonly
      Transaction.new(`#@native.transaction(#{name}, #{mode})`)
    end

    def then &block
      if @open
        Promise.resolve block.call
      else
        Promise.new do |p|
          @thens << proc { p.resolve block.call }
        end
      end
    end

    def deserialize klass, native
      `Object.assign(#{klass.allocate}, #{native})`
    end

    class ObjectStore
      def initialize native
        @native = native
      end

      def create_index name, key_path=name, unique: false
        `#@native.createIndex(#{name}, #{key_path}, { unique: #{unique} })`
      end

      def add object
        `#@native.add(#{object})`
      end

      def put object
        `#@native.put(#{object})`
      end

      def delete key
        p = Promise.new
        key = yield Query.new if block_given?

        request = Request.new(`#@native.delete(#{key})`)
        request.on(:success) { p.resolve }
        request.on(:error) { |error| p.reject error }

        p
      end

      def get key
        p = Promise.new
        key = yield Query.new if block_given?

        request = Request.new(`#@native.get(#{key})`)
        request.on :success do |event|
          js_obj = `#{event.target}.result`
          if `!!#{js_obj}`
            p.resolve `Object.assign(#{klass.allocate}, #{js_obj})`
          else
            p.resolve nil
          end
        end
        request.on(:error) { |event| p.reject event.target.result }

        p
      end

      def get_all klass, count: nil, index: nil, &block
        if index
          return index(index).get_all(klass, count: count, &block)
        end

        Promise.new do |p|
          query = block_given? ? yield(Query.new) : `undefined`

          request = Request.new(`#@native.getAll(#{query}, #{count || `undefined`})`)
          request.on :success do |event|
            p.resolve event.target.result.map { |js_obj|
              `delete #{js_obj}.$$id` # Remove old Ruby runtime metadata
              `Object.assign(#{klass.allocate}, #{js_obj})`
            }
          end
          request.on :error do |event|
            p.reject event.target.result
          end
        end
      end

      def index name
        Index.new(`#@native.index(#{name})`)
      end
    end

    class Index
      def initialize native
        @native = native
      end

      def get klass, key
        p = Promise.new
        key = yield Query.new if block_given?

        request = Request.new(`#@native.get(#{key})`)
        request.on :success do |event|
          begin
            p.resolve `Object.assign(#{klass.allocate}, #{event.target.result})`
          rescue NoMethodError # Happens when there is no result above :-\
            p.resolve nil
          end
        end

        request.on :error do |event|
          p.reject event.target.result
        end

        p
      end

      def get_all klass, count: `undefined`
        p = Promise.new

        query = if block_given?
                  yield Query.new
                else
                  `undefined`
                end

        request = Request.new(`#@native.getAll(#{query}, #{count})`)
        request.on :success do |event|
          p.resolve event.target.result.map { |js_obj|
            `delete #{js_obj}.$$id` # Remove old Ruby runtime metadata
            `Object.assign(#{klass.allocate}, #{js_obj})`
          }
        end
        request.on :error do |event|
          p.reject event.target.result
        end

        p
      end

      def cursor klass, direction: :next, count: `undefined`
        query = block_given? ? (yield Query.new) : `undefined`

        Promise.new do |p|
          results = []
          req = `#@native.openCursor(#{query}, #{direction})`
          index = 0

          %x{
            req.onsuccess = #{proc { |event|
              cursor = `event.target.result`
              if `#{cursor}`
                js_obj = `#{cursor}.value`
                `delete #{js_obj}.$$id` # Remove old Ruby runtime metadata

                value = `Object.assign(#{klass.allocate}, #{js_obj})`
                `results.push(value)`

                if `count != null && (++index < count)`
                  `#{cursor}.continue()`
                else
                  p.resolve results
                end
              else
                p.resolve results
              end
            }};
            req.onerror = #{proc { |e| p.reject e }};
          }
        end
      end
    end

    class Query
      name = %w(
        IDBKeyRange
        msIDBKeyRange
        mozIDBKeyRange
        webkitIDBKeyRange
      ).find { |name| `!!window[#{name}]` }
      NATIVE = `window[#{name}]`

      def > value
        lower_bound value, true
      end

      def >= value
        lower_bound value
      end

      def < value
        upper_bound value, true
      end

      def <= value
        upper_bound value
      end

      def == value
        `#{NATIVE}.only(#{value})`
      end

      def lower_bound value, exclusive=false
        `#{NATIVE}.lowerBound(value, exclusive)`
      end

      def upper_bound value, exclusive=false
        `#{NATIVE}.upperBound(value, exclusive)`
      end
    end

    class Transaction
      include Bowser::EventTarget

      def initialize native
        @native = native
      end

      def object_store name=`#@native.objectStoreNames[0]`
        ObjectStore.new(`#@native.objectStore(#{name})`)
      end
    end

    class Request
      include Bowser::EventTarget

      def initialize native
        @native = native
      end
    end
  end
end
