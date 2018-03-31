require 'bowser/element'
require 'bowser/document'

module Bowser
  describe Element do
    let(:native) { `{ tagName: 'DIV' }` }
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
        element.foo = 0

        expect(`#{native}.foo`).to eq 0
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

    describe 'attributes' do
      it 'sets and gets attributes' do
        native = `{
          attributes: {},
          tagName: 'DIV',
          setAttribute: function(attr, value) { this.attributes[attr] = value },
          getAttribute: function(attr) { return this.attributes[attr] },
        }`
        element = Element.new(native)

        element[:class] = 'foo bar'
        expect(element[:class]).to eq 'foo bar'
      end
    end

    describe 'query selectors' do
      it 'returns a single element matching a selector' do
        container = create
        expected = create(class_name: 'foo').tap do |expected|
          container.append expected
        end
        create(class_name: 'foo').tap do |another|
          container.append another
        end

        expect(container.query_selector('.foo')).to eq expected
      end

      it 'returns all elements matching a selector' do
        container = create
        first = create(class_name: 'foo')
        second = create(class_name: 'foo')

        container.append first
        container.append second

        expect(container.query_selector_all('.foo')).to include first, second
      end

      def create type=:div, class_name: nil
        Bowser.document.create_element(type).tap do |el|
          el.className = class_name
        end
      end
    end
  end
end
