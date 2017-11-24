require 'promise'

module Bowser
  class ServiceWorker
    NotSupported = Class.new(StandardError)

    def self.register path, options={}
      p = Promise.new

      if supported?
        %x{
          navigator.serviceWorker.register(#{path}, #{options.to_n})
            .then(#{proc { |reg| p.resolve new(reg) }})
            .catch(#{proc { |error| p.fail error}});
        }
      else
        p.reject NotSupported.new('Service worker is not supported in this browser')
      end

      p
    end

    def self.ready &block
      `navigator.serviceWorker.ready.then(#{proc { |sw| block.call new(sw) }})`
    end

    def self.supported?
      `'serviceWorker' in navigator`
    end

    def initialize native
      @native = native
    end

    def scope
      `#@native.scope`
    end

    def to_n
      @native
    end
  end
end
