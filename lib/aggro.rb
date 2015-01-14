require 'aggro/version'

require 'active_support/core_ext/hash/keys'
require 'consistent_hashing'
require 'fileutils'
require 'msgpack'
require 'yaml'

require 'aggro/abstract_store'

require 'aggro/message/command'
require 'aggro/message/heartbeat'

require 'aggro/aggregate_ref'
require 'aggro/cluster_config'
require 'aggro/event_serializer'
require 'aggro/flat_file_store'
require 'aggro/local_node'
require 'aggro/message_router'
require 'aggro/nanomsg_transport'
require 'aggro/node'
require 'aggro/node_list'

# Public: Module for namespacing and configuration methods.
module Aggro
  Event = Struct.new(:name, :occured_at, :details)
  EventStream = Struct.new(:id, :type, :events)

  MESSAGE_TYPES = {
    '1' => Message::Heartbeat,
    '2' => Message::Command
  }.freeze

  class << self
    attr_writer :data_dir
    attr_writer :transport
  end

  module_function

  def cluster_config
    @cluster_config ||= ClusterConfig.new cluster_config_path
  end

  def cluster_config_path
    [data_dir, 'cluster.yml'].join('/')
  end

  def data_dir
    @data_dir ||= begin
      './tmp/aggro'.tap do |dir|
        FileUtils.mkdir_p dir
      end
    end
  end

  def node_list
    @node_list ||= begin
      NodeList.new.tap do |node_list|
        nodes = cluster_config.nodes
        nodes.each { |name, server| node_list.add Node.new(name, server) }
        node_list.add LocalNode.new(cluster_config.node_name)
      end
    end
  end

  def port
    @port ||= ENV.fetch('PORT') { 5000 }.to_i
  end

  def transport
    @transport ||= NanomsgTransport
  end
end
