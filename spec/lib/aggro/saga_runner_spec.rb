RSpec.describe SagaRunner do
  subject(:runner) { SagaRunner.new id }

  let(:id) { SecureRandom.uuid }

  let(:saga) { spy }
  let(:handler) { -> { @ran = true } }
  let(:saga_class) do
    double new: saga, initial: :first_step, handler_for_step: handler
  end

  before do
    stub_const 'TestSaga', saga_class

    config = double(server_node?: true, node_name: SecureRandom.uuid, nodes: [])
    allow(Aggro).to receive(:cluster_config).and_return config
  end

  describe '#apply_command' do
    context 'the command is a StartSaga' do
      let(:details) { { test: 'foo' } }
      let(:command) do
        SagaRunner::StartSaga.new name: 'TestSaga', id: id, details: details
      end

      it 'should create a new saga based on the given name' do
        runner.send :apply_command, command
        expect(saga_class).to have_received(:new)
      end

      it 'should set @runner on the saga' do
        runner.send :apply_command, command
        expect(saga.instance_variable_get(:@runner)).to eq runner
      end

      it 'should execute the initial step' do
        runner.send :apply_command, command
        expect(saga.instance_variable_get(:@ran)).to be_truthy
      end
    end
  end
end
