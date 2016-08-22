require 'bowser/websocket'

module Bowser
  describe WebSocket do
    %x{
      var FakeSocket = function() {};

      FakeSocket.prototype = {
        dispatchEvent: function(event){
          var handler = 'on' + event.type;
          if(handler in this) { this[handler](event); }
        },

        close: function(reason) {
          this.dispatchEvent({
            type: 'close',
            reason: reason,
          });
        }
      };
    }

    let(:native) { `new FakeSocket()` }
    let(:socket) { WebSocket.new('url', native: native) }

    it 'knows when it is connected' do
      expect(socket).not_to be_connected

      `#{native}.dispatchEvent({ type: 'open' })`
      expect(socket).to be_connected

      `#{native}.dispatchEvent({ type: 'close' })`
      expect(socket).not_to be_connected
    end

    context 'closing the socket' do
      before do
        `#{native}.dispatchEvent({ type: 'open' })`
      end

      it 'can be closed' do
        socket.close
        expect(socket).not_to be_connected
      end

      it 'can be closed with a reason' do
        socket.on :close do |event|
          expect(event.reason).to eq 'lol'
        end
        socket.close 'lol'
      end
    end
  end
end
