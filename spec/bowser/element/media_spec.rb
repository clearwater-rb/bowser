require 'bowser/element/media'

module Bowser
  class Element
    RSpec.describe 'media extensions' do
      let(:native) do
        {
          tagName: 'VIDEO',
          buffered: time_ranges,
          played: time_ranges,
          seekable: time_ranges,
        }.to_n
      end
      let(:time_ranges) do
        {
          length: blocks.length,
          start: proc { |i| blocks[i].start },
          end: proc { |i| blocks[i].end }
        }
      end
      let(:blocks) do
        [
          time_range.new(0, 10),
          time_range.new(15, 20),
        ]
      end
      let(:time_range) do
        Class.new do
          attr_reader :start, :end
          def initialize start, _end
            @start = start
            @end = _end
          end
        end
      end

      it 'grabs time ranges' do
        element = Element.new(native)

        [element.buffered, element.played, element.seekable].each do |ranges|
          expect(ranges.map(&:start)).to eq [0, 15]
          expect(ranges.map(&:end)).to eq [10, 20]
        end
      end
    end
  end
end
