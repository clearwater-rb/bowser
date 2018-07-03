require 'bowser/event_target'
require 'bowser/promise'

module Bowser
  class FileList
    include Enumerable

    # @param native [JS] the native FileList object to wrap
    def initialize native
      @native = `#{native} || []`
      @files = length.times.each_with_object([]) { |index, array|
        array[index] = File.new(`#@native[index]`)
      }
    end

    # @param index [Integer] the index of the file in the list
    # @return [Bowser::FileList::File] the file at the specified index
    def [] index
      @files[index]
    end

    # @return [Integer] the number of files in this list
    def length
      `#@native.length`
    end
    alias size length

    # Call the given block for each file in the list
    #
    # @yieldparam file [Bowser::FileList::File]
    def each &block
      @files.each do |file|
        block.call file
      end
    end

    # Convert this FileList into an array
    def to_a
      @files.dup # Don't return a value that can mutate our internal state
    end
    alias to_ary to_a

    # @return [String] a string representation of this FileList
    def to_s
      @files.to_s
    end

    # An individual item in a FileList
    class File
      attr_reader :data

      # @param native [JS] the native File object to wrap
      def initialize native
        @native = native
        @data = nil
      end

      # @return [String] the filename
      def name
        `#@native.name`
      end

      # @return [Integer] the size of this file on disk
      def size
        `#@native.size`
      end

      # @return [String] the MIME type of the file, detected by the browser
      def type
        `#@native.type`
      end

      # @return [Time] the timestamp of the file
      def last_modified
        `#@native.lastModifiedDate`
      end

      # Read the file from disk into memory
      #
      # @return [Promise] a promise that resolves when finished loading and
      #   rejects if an error occurs while loading.
      def read
        promise = Promise.new
        reader = FileReader.new
        reader.on :load do
          result = reader.result

          @data = result
          promise.resolve result
        end

        reader.on :error do
          promise.reject reader.result
        end

        reader.read_as_binary_string self

        promise
      end

      # Convert to the native object
      #
      # @return [JS.HTMLElement] the underlying native element
      def to_n
        @native
      end

      # The object that reads the file from disk.
      #
      # @api private
      class FileReader
        include EventTarget

        def initialize
          @native = `new FileReader()`
        end

        def result
          `#@native.result`
        end

        def read_as_binary_string file
          `#@native.readAsBinaryString(#{file.to_n})`
        end
      end
    end
  end
end
