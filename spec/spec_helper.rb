if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    Aggro.reset
    FileUtils.mkdir_p './tmp/test'
    Aggro.data_dir = './tmp/test'
  end

  config.after(:each) do
    FileUtils.rm_r './tmp/test' if File.exist? './tmp/test'
  end
end

require 'aggro'

Aggro.constants.each do |const|
  eval "#{const} = Aggro::#{const}"
end

STORE_DIR = './tmp/test/data'
CLUSTER_CONFIG_PATH = './tmp/test/cluster.yml'

Thread.abort_on_exception = true
