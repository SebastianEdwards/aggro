describe AbstractStore do
  subject(:store) { AbstractStore.new }

  describe '#read' do
    it 'should raise not implemented error' do
      expect { store.read(double) }.to raise_error NotImplementedError
    end
  end

  describe '#write' do
    it 'should raise not implemented error' do
      expect { store.write(double) }.to raise_error NotImplementedError
    end
  end
end
