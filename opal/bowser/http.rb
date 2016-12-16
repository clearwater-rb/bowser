require 'native'
require 'promise'

require 'bowser/http/request'
require 'bowser/http/form_data'

module Bowser
  module HTTP
    module_function

    def fetch(url, method: :get, headers: {}, data: nil, &block)
      promise = Promise.new
      request = Request.new(method, url)

      connect_events_to_promise request, promise

      block.call(request) if block_given?
      request.send(data: data, headers: headers)

      promise
    end

    def upload(url, data, content_type: 'application/json', method: :post, &block)
      promise = Promise.new
      request = Request.new(method, url)

      connect_events_to_promise request, promise

      block.call(request) if block_given?
      request.send(data: data, headers: { 'Content-Type' => content_type })

      promise
    end

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

    def upload_file(url, file, key: 'file', method: :post, &block)
      upload_files(url, [file], key: key, key_suffix: nil, method: method, &block)
    end

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
