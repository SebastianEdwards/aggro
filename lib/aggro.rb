require 'aggro/version'

require 'active_model'
require 'active_support/core_ext/hash/keys'
require 'concurrent'
require 'consistent_hashing'
require 'fileutils'
require 'msgpack'
require 'yaml'

require 'aggro/abstract_store'

require 'aggro/message/ask'
require 'aggro/message/command'
require 'aggro/message/heartbeat'
require 'aggro/message/invalid_target'
require 'aggro/message/ok'
require 'aggro/message/unknown_command'

require 'aggro/handler/command'

require 'aggro/transform/id'
require 'aggro/transform/integer'
require 'aggro/transform/string'

require 'aggro/aggregate'
require 'aggro/aggregate_channel'
require 'aggro/aggregate_loader'
require 'aggro/aggregate_ref'
require 'aggro/client'
require 'aggro/cluster_config'
require 'aggro/command'
require 'aggro/event_serializer'
require 'aggro/flat_file_store'
require 'aggro/local_node'
require 'aggro/locator'
require 'aggro/message_parser'
require 'aggro/message_router'
require 'aggro/nanomsg_transport'
require 'aggro/node'
require 'aggro/node_list'
require 'aggro/server'
require 'aggro/threaded_aggregate'

# Public: Module for namespacing and configuration methods.
module Aggro
  Event = Struct.new(:name, :occured_at, :details)
  EventStream = Struct.new(:id, :type, :events)

  MESSAGE_TYPES = Message
                  .constants
                  .map { |sym| Message.const_get sym }
                  .select { |m| m.const_defined? 'TYPE_CODE' }
                  .each_with_object({}) { |m, h| h.merge! m::TYPE_CODE => m }
                  .freeze

  class << self
    attr_writer :data_dir
    attr_writer :transport
  end

  module_function

  def aggregate_channels
    if cluster_config.server_node?
      @aggregate_channels ||= begin
        Aggro.store.all.reduce({}) do |channels, stream|
          channels.merge stream.id => AggregateChannel.new(stream.id)
        end
      end
    else
      @aggregate_channels ||= {}
    end
  end

  def cluster_config
    @cluster_config ||= ClusterConfig.new cluster_config_path
  end

  def cluster_config_path
    [data_dir, 'cluster.yml'].join('/')
  end

  def command_bus
    @command_bus ||= CommandBus.new
  end

  def data_dir
    @data_dir ||= begin
      './tmp/aggro'.tap do |dir|
        FileUtils.mkdir_p dir
      end
    end
  end

  def local_node
    @local_node ||= LocalNode.new(cluster_config.node_name)
  end

  def node_list
    @node_list ||= begin
      NodeList.new.tap do |node_list|
        nodes = cluster_config.nodes
        nodes.each { |name, server| node_list.add Node.new(name, server) }
        node_list.add local_node if cluster_config.server_node?
      end
    end
  end

  def port
    @port ||= ENV.fetch('PORT') { 5000 }.to_i
  end

  def reset
    @cluster_config = nil
    @local_node = nil
    @node_list = nil
    @port = nil
  end

  def store
    @store ||= FlatFileStore.new(data_dir)
  end

  def transport
    @transport ||= NanomsgTransport
  end
end
