module Aggro
  # Public: Stores the current cluster config. Persists to disk after changes.
  class ClusterConfig
    attr_reader :node_name

    def initialize(path)
      @path = path

      if File.exist? path
        load_config
      else
        initialize_config
        persist_config
      end
    end

    def add_node(name, server)
      @nodes = nodes.merge(name => server).freeze
      persist_config
    end

    def nodes
      @nodes ||= {}.freeze
    end

    def server_node=(value)
      @is_server_node = value
      persist_config
    end

    def server_node?
      @is_server_node == true
    end

    private

    def initialize_config
      @node_name = SecureRandom.uuid
      @is_server_node = false
    end

    def load_config
      YAML.load_file(@path).each do |key, value|
        instance_variable_set "@#{key}", value.freeze
      end
    end

    def persist_config
      File.open @path, 'w' do |file|
        file.write YAML.dump to_h
      end
    end

    def to_h
      {
        node_name: node_name,
        nodes: nodes,
        is_server_node: server_node?
      }
    end
  end
end
