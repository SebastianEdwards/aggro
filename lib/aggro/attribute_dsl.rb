module Aggro
  # Public: Adds a DSL defining attributes and validations.
  module AttributeDSL
    extend ActiveSupport::Concern

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    def initialize(attrs = {})
      if Thread.current[:causation_id] && respond_to?(:causation_id=)
        attrs.merge! causation_id: Thread.current[:causation_id]
      end

      if Thread.current[:correlation_id] && respond_to?(:correlation_id=)
        attrs.merge! correlation_id: Thread.current[:correlation_id]
      end

      super
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
        Aggro.class_attributes[name]
      end

      def attribute(name)
        create_attrs name, Transform::NOOP
      end

      def boolean(name)
        create_attrs name, Transform::Boolean
      end

      def date(name)
        create_attrs name, Transform::Date
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

      def money(name)
        require 'money'
        require 'monetize'

        create_attrs name, Transform::Money
      rescue LoadError
        puts '`money` and `monetize` gems must be present to use money type'
      end

      def string(name)
        create_attrs name, Transform::String
      end

      def time(name)
        create_attrs name, Transform::Time
      end

      def time_interval(name)
        require 'time-interval'

        create_attrs name, Transform::TimeInterval
      rescue LoadError
        puts '`time-interval` gem must be present to use time_interval type'
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
