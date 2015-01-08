require 'aggro/version'

require 'active_support/core_ext/hash/keys'
require 'consistent_hashing'
require 'fileutils'
require 'msgpack'

require 'aggro/abstract_store'

require 'aggro/aggregate_ref'
require 'aggro/event_serializer'
require 'aggro/flat_file_store'
require 'aggro/node_list'

# Public: Module for namespacing and configuration methods.
module Aggro
  Event = Struct.new(:name, :occured_at, :details)
  EventStream = Struct.new(:id, :type, :events)

  # Public: Value object for server node.
  class Node < Struct.new(:id, :server)
    def to_s
      id
    end
  end

  def self.initialize_node_list(servers = servers_from_env)
    NodeList.new.tap do |ring|
      servers.each { |server| ring.add Node.new(server, server) }
    end
  end

  def self.node_list
    @node_list ||= initialize_node_list
  end

  def self.servers_from_env
    ENV['AGGRO_SERVERS'] ? ENV['AGGRO_SERVERS'].split(',') : []
  end
end
