require 'bowser/element'

module Bowser
  describe Element do
    let(:native) { `{}` }
    let(:element) { Element.new(native) }

    describe :type do
      it 'returns the type of the native element' do
        `#{native}.nodeName = 'INPUT'`

        expect(element.type).to eq 'input'
      end
    end

    describe :clear do
      let(:native) { `document.createElement('div')` }

      it 'relieves an element of its child nodes' do
        element.append `document.createElement('span')`

        element.clear

        expect(element).to be_empty
      end
    end

    context 'proxying native properties/methods' do
      it 'passes through to native properties' do
        `#{native}.foo = "bar"`

        expect(element.foo).to eq 'bar'
      end

      it 'calls native methods' do
        `#{native}.foo = function(bar) { return 'baz' + bar }`

        expect(element.foo(1)).to eq 'baz1'
      end

      it 'camelizes property names' do
        %x{
          #{native}.fooBar = 'fooBar';
          #{native}.bazQuux = function() { return 'lol' };
        }

        expect(element.foo_bar).to eq 'fooBar'
        expect(element.baz_quux).to eq 'lol'
      end

      it 'proxies predicate methods' do
        %x{
          #{native}.isFoo = true;
          #{native}.bar = false;
        }

        expect(element.foo?).to be true
        expect(element.bar?).to be false
      end

      it 'proxies setting properties' do
        element.foo = 'bar'

        expect(`#{native}.foo`).to eq 'bar'
      end
    end

    it 'can be converted back into a native element' do
      expect(`#{element.to_n} === #{native}`).to be_truthy
    end

    describe :== do
      let(:native) { `document.createElement('div')` }

      it 'is equal to instances wrapping the same native element' do
        same = Element.new(native)
        expect(element == same).to be_truthy
      end

      it 'is not equal to instances wrapping other native elements' do
        other = Element.new(`document.createElement('div')`)
        expect(element == other).to be_falsey
      end
    end
  end
end
