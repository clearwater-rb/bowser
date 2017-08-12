require 'promise'

module Bowser
  class Geolocation
    class Error < StandardError
      def self.from_native native
        new(`#{native}.error`, native)
      end

      def initialize(message, native)
        super(message)
        @native = native
      end
    end
    class PositionError < Error
      def denied?
        `#@native.code === 1`
      end

      def unavailable?
        `#@native.code === 2`
      end

      def timeout?
        `#@native.code === 3`
      end
    end
    NotSupported = Class.new(Error)

    attr_reader :latitude, :longitude, :accuracy, :altitude, :altitude_accuracy, :heading, :speed, :timestamp

    @native = `navigator.geolocation`

    def self.supported?
      `'geolocation' in navigator`
    end

    def self.locate options={}
      p = Promise.new

      if supported?
        %x{
          #@native.getCurrentPosition(
            #{proc { |position| `console.log(position)`; p.resolve(from_native(position)) }},
            #{proc { |error| `console.error(error)`; p.reject(PositionError.from_native(error)) }},
            #{Options.new(options).to_n}
          )
        }
      else
        p.reject NotSupported.new('Geolocation is not supported on this device.')
      end

      p
    end

    def self.watch(options={})
      Watch.new(options)
    end

    def self.from_native native
      coords = `#{native}.coords`
      new(
        latitude: `coords.latitude`,
        longitude: `coords.longitude`,
        altitude: `coords.altitude`,
        accuracy: `coords.accuracy`,
        altitude_accuracy: `coords.altitudeAccuracy`,
        heading: `coords.heading`,
        speed: `coords.speed || nil`,
        timestamp: `#{native}.timestamp`,
      )
    end

    def initialize(latitude:, longitude:, accuracy:, altitude: nil, altitude_accuracy: nil, heading: nil, speed: nil, timestamp:)
      @latitude = latitude
      @longitude = longitude
      @altitude = altitude
      @accuracy = accuracy
      @altitude_accuracy = altitude_accuracy
      @heading = heading
      @speed = speed
      @timestamp = Time.at(timestamp / 1000)
    end

    class Watch
      def initialize(options)
        @options = Options.new(options)
        @events = Hash.new { |h,k| h[k] = [] }
      end

      def on event_name, &block
        @events[event_name] << block
      end

      def start
        %x{
          #@id = navigator.geolocation.watchPosition(
            #{proc { |position| success Geolocation.from_native(position) } },
            #{proc { |error| error PositionError.from_native(error) }},
            #{@options.to_n}
          )
        }
      end

      def stop
        `navigator.geolocation.clearWatch(#@id)`
      end

      def success location
        @events[:location].each { |callback| callback.call location }
      end

      def error error
        @events[:error].each { |callback| callback.call error }
      end
    end

    class Options
      def initialize(high_accuracy: nil,
                     max_age: nil,
                     timeout: nil)
        @high_accuracy = high_accuracy
        @max_age = max_age && max_age * 1000 # convert to milliseconds
        @timeout = timeout && timeout * 1000
      end

      def to_n
        {
          enabledHighAccuracy: @high_accuracy,
          maximumAge: @max_age,
          timeout: @timeout,
        }.reject { |k, v| v.nil? }.to_n
      end
    end
  end
end
