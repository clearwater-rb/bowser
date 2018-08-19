module Bowser
  class Cookie
    def self.all
      native
        .split(';')
        .map { |cookie| from_native(cookie) }
    end

    def self.[] key
      all.find { |cookie| cookie.key == key }
    end

    def self.delete key
      `document.cookie = #{"#{key}=; expires=#{`#{Time.now}.toUTCString()`}"}`
      nil
    end

    def self.from_native string
      new *string.split('=', 2)
    end

    def self.native
      `document.cookie`
    end

    def self.set **attrs
      attrs.map do |key, value|
        new(key, value).set
      end
    end

    attr_reader :key, :value

    def initialize key, value, **options
      @key = key.strip
      @value = value
      @options = options
    end

    def delete
      `document.cookie = "#@key=; expires=0"`
      nil
    end

    def set
      options = @options.map do |opt, value|
        "; #{opt}=#{
          case value
          when Date
            `#{value}.toUTCString()`
          else
            value
          end
        }"
      end

      `document.cookie = #{"#@key=#@value#{options.join}"}`
      self
    end
  end
end
