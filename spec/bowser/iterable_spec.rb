require 'bowser/iterable'

module Bowser
  RSpec.describe Iterable do
    it 'converts a JS iterable to an Enumerable' do
      js_iterable = `{
        length: 3,
        0: 'a',
        1: 'b',
        2: 'c',
      }`

      expect(Iterable.new(js_iterable).map(&:upcase)).to eq %w(A B C)
    end
  end
end
