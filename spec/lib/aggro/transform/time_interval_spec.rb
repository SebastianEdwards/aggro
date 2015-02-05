require 'time-interval'

RSpec.describe Transform::TimeInterval do
  let(:interval_str) { '2007-03-01T13:00:00Z/P1M' }
  let(:interval) { TimeInterval.parse interval_str }

  let(:repeating_str) { 'R2/2007-03-01T13:00:00Z/P1M' }
  let(:repeating) { TimeInterval.parse repeating_str }

  describe '.deserialize' do
    it 'should transform strings to a TimeInterval' do
      deserialized = Transform::TimeInterval.deserialize(interval_str)

      expect(deserialized.start_time).to eq interval.start_time
      expect(deserialized.end_time).to eq interval.end_time
    end

    it 'should return nil if not a string or TimeInterval' do
      expect(Transform::TimeInterval.deserialize(true)).to eq nil
    end
  end

  describe '.serialize' do
    it 'should transform the value to a string' do
      expect(Transform::TimeInterval.serialize(interval)).to eq interval_str
      expect(Transform::TimeInterval.serialize(repeating)).to eq repeating_str
    end
  end
end
