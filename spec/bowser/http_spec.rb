require 'bowser/http'

module Bowser
  RSpec.describe HTTP do
    let(:request) { double("request").as_null_object }
    before { allow(HTTP::Request).to receive(:new) { request } }

    specify 'methods yield request when block is given' do
      expect { |b| HTTP.fetch(:url, &b) }.to yield_with_args(request)
      expect { |b| HTTP.upload(:url, :data, &b) }.to yield_with_args(request)
      expect { |b| HTTP.upload_files(:url, [], &b) }.to yield_with_args(request)
      expect { |b| HTTP.upload_file(:url, :file, &b) }.to yield_with_args(request)
    end
  end
end

