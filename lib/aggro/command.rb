module Aggro
  # Public: Mixin to turn a PORO into an Aggro command.
  module Command
    extend ActiveSupport::Concern
    include ActiveModel::Model

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
