require 'aggro/version'

require 'active_model'
require 'active_support/core_ext/hash/keys'
require 'concurrent'
require 'consistent_hashing'
require 'invokr'
require 'fileutils'
require 'msgpack'
require 'yaml'

require 'aggro/abstract_store'
require 'aggro/attribute_dsl'
require 'aggro/event_dsl'

require 'aggro/message/ask'
require 'aggro/message/command'
require 'aggro/message/command_unhandled'
require 'aggro/message/command_unknown'
require 'aggro/message/create_aggregate'
require 'aggro/message/endpoint'
require 'aggro/message/events'
require 'aggro/message/get_events'
require 'aggro/message/heartbeat'
require 'aggro/message/invalid_target'
require 'aggro/message/ok'
require 'aggro/message/publisher_endpoint_inquiry'
require 'aggro/message/saga_unknown'
require 'aggro/message/start_saga'

require 'aggro/handler/command'
require 'aggro/handler/create_aggregate'
require 'aggro/handler/get_events'
require 'aggro/handler/start_saga'

require 'aggro/transform/email'
require 'aggro/transform/id'
require 'aggro/transform/integer'
require 'aggro/transform/string'

require 'aggro/aggregate'
require 'aggro/aggregate_ref'
require 'aggro/binding_dsl'
require 'aggro/block_helper'
require 'aggro/channel'
require 'aggro/client'
require 'aggro/cluster_config'
require 'aggro/command'
require 'aggro/concurrent_actor'
require 'aggro/event_bus'
require 'aggro/event_proxy'
require 'aggro/event_serializer'
require 'aggro/file_store'
require 'aggro/local_node'
require 'aggro/locator'
require 'aggro/message_parser'
require 'aggro/message_router'
require 'aggro/nanomsg_transport'
require 'aggro/node'
require 'aggro/node_list'
require 'aggro/projection'
require 'aggro/saga'
require 'aggro/saga_promise'
require 'aggro/server'
require 'aggro/subscriber'

# Public: Module for namespacing and configuration methods.
module Aggro
  ClientNode = Struct.new(:id)

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

  def channels
    if cluster_config.server_node?
      @channels ||= begin
        Aggro.store.registry.reduce({}) do |channels, (id, type)|
          channels.merge id => Channel.new(id, type)
        end
      end
    else
      @channels ||= {}
    end
  end

  def cluster_config
    @cluster_config ||= ClusterConfig.new cluster_config_path
  end

  def cluster_config_path
    [data_dir, 'cluster.yml'].join('/')
  end

  def data_dir
    @data_dir ||= begin
      ENV.fetch('AGGRO_DIR') { './tmp/aggro' }.tap do |dir|
        FileUtils.mkdir_p dir
      end
    end
  end

  def event_bus
    @event_bus ||= EventBus.new
  end

  def local_node
    if cluster_config.server_node?
      @local_node ||= LocalNode.new(cluster_config.node_name)
    else
      @local_node ||= ClientNode.new(SecureRandom.uuid)
    end
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

  def publisher_port
    @publisher_port ||= ENV.fetch('PUBLISHER_PORT') { 6000 }.to_i
  end

  def reset
    @cluster_config = nil
    @local_node = nil
    @node_list = nil
    @port = nil
    @publisher = nil
    @publisher_port = nil
    @server = nil
    @store = nil
  end

  def server
    return unless cluster_config.server_node?

    @server ||= Server.new(local_node.endpoint, local_node.publisher_endpoint)
  end

  def store
    @store ||= FileStore.new(data_dir)
  end

  def transport
    @transport ||= NanomsgTransport
  end
end
