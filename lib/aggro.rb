require 'aggro/version'

require 'consistent_hashing'

require 'aggro/aggregate_ref'

# Public: Module for namespacing and configuration methods.
module Aggro
  def self.initialize_hash_ring(servers = servers_from_env)
    ConsistentHashing::Ring.new.tap do |ring|
      servers.each { |server| ring.add server }
    end
  end

  def self.hash_ring
    @hash_ring ||= initialize_hash_ring
  end

  def self.servers_from_env
    ENV['AGGRO_SERVERS'] ? ENV['AGGRO_SERVERS'].split(',') : []
  end
end
