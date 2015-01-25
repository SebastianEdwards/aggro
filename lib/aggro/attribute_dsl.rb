module Aggro
  # Public: Adds a DSL defining attributes and validations.
  module AttributeDSL
    extend ActiveSupport::Concern

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    def initialize(attrs = {})
      if Thread.current[:aggro_context]
        super Thread.current[:aggro_context].merge attrs
      else
        super
      end
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

    class_methods do
      def attributes
        @attributes ||= {}
      end

      def attribute(name)
        create_attrs name, Transform::NOOP
      end

      def email(name)
        create_attrs name, Transform::Email
      end

      def generate_id(name)
        create_attrs name, Transform::ID.new(generate: true)
      end

      def id(name)
        create_attrs name, Transform::ID.new
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
