require 'bowser/element'

module Bowser
  describe Element do
    let(:native) { `{}` }
    let(:element) { Element.new(native) }

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
          #{native}.bar = true;
        }

        expect(element.foo?).to be true
        expect(element.bar?).to be true
      end

      it 'proxies setting properties' do
        element.foo = 'bar'

        expect(`#{native}.foo`).to eq 'bar'
      end
    end
  end
end
