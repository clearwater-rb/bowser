require 'native'
require 'promise'

require 'bowser/http/request'
require 'bowser/http/form_data'

module Bowser
  module HTTP
    module_function

    def fetch(url)
      promise = Promise.new
      request = Request.new(:get, url)

      connect_events_to_promise request, promise

      request.send

      promise
    end

    def upload(url, data, content_type: 'application/json')
      promise = Promise.new
      request = Request.new(:post, url)

      connect_events_to_promise request, promise

      request.send(data: data, headers: { 'Content-Type' => content_type })

      promise
    end

    def upload_files(url, files, key: 'files', key_suffix: '[]')
      promise = Promise.new
      request = Request.new(:post, url)

      connect_events_to_promise request, promise

      form = FormData.new
      files.each do |file|
        form.append "#{key}#{key_suffix}", file
      end

      request.send(data: form)

      promise
    end

    def upload_file(url, file, key: 'file')
      upload_files(url, [file], key: key, key_suffix: nil)
    end

    def connect_events_to_promise(request, promise)
      request.on :success do
        promise.resolve request.response
      end
      request.on :error do |event|
        promise.reject Native(event)
      end
    end
  end
end
