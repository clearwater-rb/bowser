require 'bowser/file_list'

module Bowser
  describe FileList do
    it 'indexes like an array' do
      native = [{ name: 'foo' }, { name: 'bar' }].to_n
      file_list = FileList.new(native)

      expect(file_list[0].name).to eq 'foo'
      expect(file_list[1].name).to eq 'bar'
      expect(file_list[2]).to be_nil
    end

    it 'has Enumerable functionality' do
      native = [{ name: 'foo' }, { name: 'bar' }].to_n
      file_list = FileList.new(native)

      expect(file_list.map(&:name)).to eq ['foo', 'bar']
    end

    it 'knows its size' do
      native = [{ name: 'foo' }, { name: 'bar' }].to_n
      file_list = FileList.new(native)

      expect(file_list.size).to eq 2
    end

    describe File do
      let(:timestamp) { Time.new(2015, 12, 15, 18, 0, 0) }
      let(:native) {
        {
          name: 'foo',
          size: 123,
          type: 'text/plain',
          lastModifiedDate: timestamp,
        }.to_n
      }
      let(:file) { FileList::File.new(native) }

      it 'returns name' do
        expect(file.name).to eq 'foo'
      end

      it 'returns the file size' do
        expect(file.size).to eq 123
      end

      it 'returns the file MIME type' do
        expect(file.type).to eq 'text/plain'
      end

      it 'returns the last-modified timestamp' do
        expect(file.last_modified).to eq timestamp
      end
    end
  end
end
