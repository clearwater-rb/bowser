require 'bowser/delegate_native'

module Bowser
  RSpec.describe DelegateNative do
    klass = Class.new do
      include DelegateNative
    end

    it 'passes method calls through to the native object' do
      native = `{
        isFooBar: true,
      }`

      obj = klass.new(native)

      expect(obj.isFooBar).to eq true
      expect(obj.is_foo_bar).to eq true
      expect(obj.foo_bar?).to eq true
      expect(obj).to be_foo_bar # aww yeah
    end

    it 'raises a NoMethodError if the object does not have the property' do
      obj = klass.new(`{}`)

      expect { obj.foo }.to raise_error NoMethodError
    end

    it 'returns nil if the object has a property but it is null' do
      obj = klass.new(`{
        foo: undefined,
        bar: null,
      }`)

      expect(obj.foo).to be_nil
      expect(obj.bar).to be_nil
    end
  end
end
