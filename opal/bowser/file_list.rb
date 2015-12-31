require 'promise'

module Bowser
  class FileList
    include Enumerable

    def initialize native
      @native = `#{native} || []`
    end

    def [] index
      if index < length && index >= 0
        File.new(`#@native[index]`)
      end
    end

    def length
      `#@native.length`
    end
    alias size length

    def each &block
      length.times.each do |i|
        block.call self[i]
      end
    end

    def to_a
      map { |file| file }
    end
    alias to_ary to_a

    class File
      def initialize native
        @native = native
      end

      def name
        `#@native.name`
      end

      def size
        `#@native.size`
      end

      def type
        `#@native.type`
      end

      def last_modified
        `#@native.lastModifiedDate`
      end

      def read
        promise = Promise.new
        reader = Native(`new FileReader()`)
        reader[:onload] = proc do
          promise.resolve reader.result
        end
        reader[:onerror] = proc do
          promise.reject reader.result
        end
        reader.readAsBinaryString(`#@native`)

        promise
      end
    end
  end
end
