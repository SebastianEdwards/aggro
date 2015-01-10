RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:each) do
    FileUtils.rm_r './tmp/data' if File.directory? './tmp/data'
  end
end

require 'aggro'

Aggro.constants.each do |const|
  eval "#{const} = Aggro::#{const}"
end

ENV['AGGRO_SERVERS'] = '10.0.0.1,10.0.0.2'
STORE_DIR = './tmp/data'
