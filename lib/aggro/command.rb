module Aggro
  # Public: Mixin to turn a PORO into an Aggro command.
  module Command
    extend ActiveSupport::Concern
    include ActiveModel::Model

    included do
      generate_id :causation_id
      generate_id :correlation_id
    end

    def attributes
      self.class.attributes.keys.reduce({}) do |hash, name|
        hash.merge name => send(name)
      end
    end

    def serialized_attributes
      self.class.attributes.reduce({}) do |hash, (name, transform)|
        hash.merge name => transform.serialize(send(name))
      end
    end

    def to_details
      { name: model_name.name, args: serialized_attributes }
    end

    # Public: Adds attribute definition DSL to command.
    module ClassMethods
      def attributes
        @attributes ||= {}
      end

      def id(name)
        create_attrs name, Transform::ID.new
      end

      def generate_id(name)
        create_attrs name, Transform::ID.new(generate: true)
      end

      def integer(name)
        create_attrs name, Transform::Integer
      end

      def string(name)
        create_attrs name, Transform::String
      end

      private

      def create_attrs(name, transformer)
        attr_reader name
        attributes[name] = transformer

        define_method("#{name}=") do |value|
          transformed = self.class.attributes[name].deserialize value
          instance_variable_set "@#{name}", transformed
        end
      end
    end
  end
end
