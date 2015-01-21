module Aggro
  # Public: Adds a DSL defining event handlers.
  module EventDSL
    extend ActiveSupport::Concern

    def handles_event?(event_name, namespace = nil)
      self.class.handles_event? event_name, namespace
    end

    class_methods do
      def events(namespace = nil, &block)
        test_class = Class.new(BasicObject)
        starting_methods = test_class.instance_methods
        test_class.class_eval(&block)

        event_methods[namespace] ||= Set.new
        test_class.instance_methods.each do |meth|
          event_methods[namespace] << meth unless starting_methods.include? meth
        end

        class_eval(&block)
      end

      def handles_event?(event_name, namespace = nil)
        event_methods[namespace].include? event_name
      end

      private

      def event_methods
        @event_methods ||= {}
      end
    end
  end
end
