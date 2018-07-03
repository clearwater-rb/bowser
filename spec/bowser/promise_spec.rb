require 'bowser/promise'

module Bowser
  RSpec.describe Promise do
    it 'can transition to resolved state' do
      p = Promise.new
      p.resolve 53

      expect(p).to be_resolved
    end

    it 'can transition to rejected state' do
      p = Promise.new
      p.reject 'lol'

      expect(p).to be_rejected
    end

    it 'creates a resolved promise' do
      expect(Promise.resolve).to be_resolved
    end

    it 'creates a rejected promise' do
      expect(Promise.reject(nil)).to be_rejected
    end

    context 'when resolved' do
      let(:promise) { Promise.resolve(42) }

      it 'cannot transition to rejected state' do
        promise.reject 'omg'

        expect(promise).not_to be_rejected
      end

      it 'cannot change its value' do
        promise.resolve 1337

        expect(promise.value).to eq 42
      end
    end

    context 'when rejected' do
      let(:promise) { Promise.reject 'omg' }

      it 'cannot transition to resolved state' do
        promise.resolve 42

        expect(promise).to be_rejected
      end

      it 'cannot change its reason' do
        promise.reject 'zomg'

        expect(promise.value).to eq 'omg'
      end
    end

    describe 'then' do
      let(:promise) { Promise.new }

      it 'takes a block to call when the promise is resolved' do
        x = nil
        promise.then { |value| x = value }

        promise.resolve 42

        expect(x).to eq 42
      end

      it 'does not require a block' do
        p2 = promise.then
        promise.resolve 42
        expect(p2).to be_resolved
        expect(p2.value).to eq 42
      end

      it 'must not call its block more than once' do
        x = 0
        promise.then { |value| x += 1 }
        promise.resolve
        promise.resolve

        expect(x).to eq 1
      end

      it 'may be called multiple times on the same promise' do
        x = 0
        promise.then { |value| x += value }
        promise.then { |value| x += value }

        promise.resolve 1

        expect(x).to eq 2
      end

      it 'returns a promise' do
        p2 = promise.then # no block because YOLO

        expect(p2).to be_a Promise
      end

      it 'executes the block if already resolved' do
        promise.resolve 42

        x = nil
        p2 = promise.then { |value| x = value }

        expect(x).to eq 42
        expect(p2).to be_resolved
      end
    end

    describe 'catch' do
      let(:promise) { Promise.new }

      it 'takes a block to call when the promise is rejected' do
        x = nil
        promise.catch { |reason| x = reason }

        promise.reject 'omg'

        expect(x).to eq 'omg'
      end

      it 'must not be called more than once' do
        x = 0

        promise.catch { |value| x += value }
        promise.reject 1
        promise.reject 1

        expect(x).to eq 1
      end

      it 'may be called multiple times on the same promise' do
        x = 0
        promise.catch { |value| x += value }
        promise.catch { |value| x += value }

        promise.reject 1

        expect(x).to eq 2
      end

      it 'returns a resolved promise if already rejected' do
        promise.reject 'omg'

        x = nil
        p2 = promise.catch { |reason| x = reason }

        expect(x).to eq 'omg'
        expect(p2).to be_resolved
      end
    end

    describe 'promise resolution' do
      let(:promise) { Promise.new }

      it 'resolves to the value of the previous promise in the chain' do
        x = 0

        promise
          .then { 1 } # Ignore the value the previous promise resolved to
          .then { |v| x = v }

        promise.resolve 42

        expect(x).to eq 1
      end

      it 'calls subsequent `then` blocks after a rejected promise is caught' do
        catch_count = 0
        then_count = 0
        promise
          .then { then_count += 1 }
          .then { raise 'hell' }
          .catch { catch_count += 1 }
          .catch { catch_count += 1 }
          .then { then_count += 1 }

        promise.resolve 42

        # require 'pry'
        # binding.pry

        expect(then_count).to eq 2
        expect(catch_count).to eq 1
      end

      context 'when value is a thenable object' do
        let(:value) { Promise.new }

        context 'when the promise and value are identical' do
          it 'rejects with a TypeError' do
            promise.resolve promise

            expect(promise).to be_rejected
            expect(promise.value).to be_a TypeError
          end
        end

        it 'resolves with the value of the promise' do
          promise.resolve value

          value.resolve 42
          expect(promise).to be_resolved
          expect(promise.value).to eq 42
        end

        # Just a bit of a sanity check for the previous spec
        it 'handles long promise chains' do
          promises = Array.new(50) { Promise.new }

          promise.resolve promises.first
          (0...promises.length - 1).each do |index|
            promises[index].resolve promises[index + 1]
          end

          promises.last.resolve 42

          expect(promise).to be_resolved
          expect(promise.value).to eq 42
        end

        it "locks itself to the promise's value" do
          x = nil
          promise.then { |v| x = v }

          promise.resolve value
          expect(x).to be_nil

          value.resolve 42

          expect(x).to eq 42
          expect(promise.value).to eq 42
        end

        it 'rejects with the value of the promise' do
          promise.resolve value

          value.reject 'omg'
          expect(promise).to be_rejected
          expect(promise.value).to eq 'omg'
        end
      end

      context 'chained promises' do
        it 'resolves chained promises with the return value of the previous' do
          p2 = promise.then { |value| value + 1 }
          p3 = p2.then { |value| value + 1 }

          promise.resolve 1

          expect(p2.value).to eq 2
          expect(p3.value).to eq 3
        end

        it 'rejects all the way through the promise chain' do
          x = nil
          exception = nil
          promise
            .then { x = true }
            .then { x = 12 }
            .catch { |reason| exception = reason }

          promise.reject 'omg'

          expect(x).to be_nil
          expect(exception).to eq 'omg'
        end

        it 'traps exceptions and only executes catch blocks' do
          x = nil
          exception = nil
          exception2 = nil
          promise
            .then { x = :before }
            .then { raise TypeError, 'omg' }
            .then { x = :after }
            .catch { |reason| exception = reason }
            .then { |reason| exception2 = reason }

          promise.resolve nil

          expect(x).to eq :before
          expect(exception).to be_a TypeError
          expect(exception.message).to eq 'omg'
          expect(exception2).to be_a TypeError
          expect(exception2.message).to eq 'omg'
        end
      end
    end

    describe 'Promise.all' do
      it 'resolves when all promise arguments are resolved' do
        promises = Array.new(5) do
          Promise.new
        end

        p = Promise.all(promises)

        4.times do |i|
          promises[i].resolve i
          expect(p).not_to be_resolved
        end

        promises[4].resolve 4
        expect(p).to be_resolved
        expect(p.value).to eq [0, 1, 2, 3, 4]
      end

      it 'rejects if any promise arguments are rejected' do
        promises = Array.new(5) { Promise.new }

        p = Promise.all(promises)

        promises.last.resolve 42
        promises.first.reject 'omg'

        expect(p).to be_rejected
        expect(p.value).to eq 'omg'
      end
    end

    describe 'Promise.race' do
      it 'resolves when any promise argument is resolved' do
        promises = Array.new(5) { Promise.new }
        p = Promise.race(promises)

        promises.first.resolve 42

        expect(p).to be_resolved
        expect(p.value).to eq 42
      end

      it 'rejects if any are rejected first' do
        promises = Array.new(5) { Promise.new }
        p = Promise.race(promises)

        promises.first.reject 'omg'

        expect(p).to be_rejected
        expect(p.value).to eq 'omg'
      end
    end
  end
end
