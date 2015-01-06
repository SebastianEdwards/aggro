require 'aggro/version'

require 'active_support/core_ext/hash/keys'
require 'consistent_hashing'
require 'msgpack'

require 'aggro/aggregate_ref'
require 'aggro/event_serializer'

# Public: Module for namespacing and configuration methods.
module Aggro
  Event = Struct.new(:name, :occured_at, :details)

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
