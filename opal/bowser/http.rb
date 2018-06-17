require 'promise'

require 'bowser/http/request'
require 'bowser/http/form_data'

module Bowser
  module HTTP
    module_function

    # Send a request to the given URL
    #
    # @param url [String] the URL to send the request to
    # @keywordparam method [String] the HTTP method, defaults to GET
    # @keywordparam headers [Hash] the HTTP headers to send with the request
    # @keywordparam data [Hash, String, nil] the data to send with the request,
    #   only useful for POST, PATCH, or PUT requests
    def fetch(url, method: :get, headers: {}, data: nil, &block)
      promise = Promise.new
      request = Request.new(method, url)

      connect_events_to_promise request, promise

      block.call(request) if block_given?
      request.send(data: data, headers: headers)

      promise
    end

    # Shorthand method for sending a request with JSON data
    #
    # @param url [String] the URL to send the request to
    # @param data [Hash, String, nil] the data to send with the request,
    #   only useful for POST, PATCH, or PUT requests. Otherwise, use `fetch`.
    # @keywordparam method [String] the HTTP method, defaults to GET
    # @keywordparam content_type [String] the MIME type of the request
    def upload(url, data, content_type: 'application/json', method: :post, &block)
      promise = Promise.new
      request = Request.new(method, url)

      connect_events_to_promise request, promise

      block.call(request) if block_given?
      request.send(data: data, headers: { 'Content-Type' => content_type })

      promise
    end

    # Upload files from a file input field
    #
    # @param url [String] the URL to send the request to
    # @param files [Bowser::FileList] the files to attach
    # @keywordparam key [String] the name to use for the POST param, defaults to `"files"`
    # @keywordparam key_suffix [String] the suffix for the key, defaults to
    #   `"[]"`. This is how several web frameworks determine that the key should
    #   be treated as an array.
    # @keywordparam method [String] the HTTP method to use, defaults to `"POST"`
    def upload_files(url, files, key: 'files', key_suffix: '[]', method: :post, &block)
      promise = Promise.new
      request = Request.new(method, url)

      connect_events_to_promise request, promise

      form = FormData.new
      files.each do |file|
        form.append "#{key}#{key_suffix}", file
      end

      block.call(request) if block_given?
      request.send(data: form)

      promise
    end

    # Upload a single file from a file input field
    #
    # @param url [String] the URL to send the request to
    # @param file [Bowser::File] the file to attach
    # @keywordparam key [String] the name to use for the POST param, defaults to `"files"`
    # @keywordparam method [String] the HTTP method to use, defaults to `"POST"`
    def upload_file(url, file, key: 'file', method: :post, &block)
      upload_files(url, [file], key: key, key_suffix: nil, method: method, &block)
    end

    # @api private
    def connect_events_to_promise(request, promise)
      request.on :load do
        promise.resolve request.response
      end
      request.on :error do |event|
        promise.reject Native(event)
      end
    end
  end
end
