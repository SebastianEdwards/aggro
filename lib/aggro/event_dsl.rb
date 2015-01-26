module Aggro
  # Public: Adds a DSL defining event handlers.
  module EventDSL
    extend ActiveSupport::Concern

    def handles_event?(event_name, namespace = nil)
      self.class.handles_event? event_name, namespace
    end

    class_methods do
      def events(namespace = nil, &block)
        new_methods = BlockHelper.method_definitions(&block)

        event_methods[namespace] ||= Set.new
        new_methods.each { |method| event_methods[namespace] << method }

        class_eval(&block)

        class_eval do
          new_methods.each do |method|
            alias_method "#{namespace}_#{method}", method
            remove_method method
          end
        end
      end

      def handles_event?(event_name, namespace = nil)
        namespace?(namespace) && event_methods[namespace].include?(event_name)
      end

      def namespace?(namespace)
        !event_methods[namespace].nil?
      end

      private

      def event_methods
        @event_methods ||= {}
      end
    end
  end
end
