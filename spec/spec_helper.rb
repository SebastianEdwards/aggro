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
    FileUtils.mkdir_p './tmp/test/aggro'
  end

  config.after(:each) do
    FileUtils.rm_r './tmp/test/aggro' if File.directory? './tmp/test/aggro'
  end
end

require 'aggro'

Aggro.constants.each do |const|
  eval "#{const} = Aggro::#{const}"
end

Aggro.data_dir = './tmp/test'

STORE_DIR = './tmp/test/aggro/data'
CLUSTER_CONFIG_PATH = './tmp/test/aggro/cluster.yml'
