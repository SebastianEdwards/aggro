require 'money'
require 'monetize'

RSpec.describe Transform::Money do
  let(:ten_usd) { Money.new(1000, 'USD') }
  let(:five_nzd) { Money.new(500, 'NZD') }

  describe '.deserialize' do
    it 'should transform strings to a Money' do
      expect(Transform::Money.deserialize('$10.00 USD')).to eq ten_usd
      expect(Transform::Money.deserialize('$5.00 NZD')).to eq five_nzd
    end

    it 'should default to USD' do
      expect(Transform::Money.deserialize('$10.00')).to eq ten_usd
      expect(Transform::Money.deserialize('$5.00')).to_not eq five_nzd
    end

    it 'should accept an integer' do
      expect(Transform::Money.deserialize(10)).to eq ten_usd
    end

    it 'should return nil if not a string' do
      expect(Transform::Money.deserialize(true)).to eq nil
    end
  end

  describe '.serialize' do
    it 'should transform the value to a string' do
      expect(Transform::Money.serialize(ten_usd)).to eq '$10.00 USD'
      expect(Transform::Money.serialize(five_nzd)).to eq '$5.00 NZD'
    end
  end
end
