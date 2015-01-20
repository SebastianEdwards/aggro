module Aggro
  # Public: Adds a DSL defining event handlers.
  module EventDSL
    extend ActiveSupport::Concern

    def handles_event?(event_name)
      self.class.handles_event? event_name
    end

    class_methods do
      def events(&block)
        test_class = Class.new(BasicObject)
        starting_methods = test_class.instance_methods
        test_class.class_eval(&block)

        test_class.instance_methods.each do |method|
          event_methods << method unless starting_methods.include? method
        end

        class_eval(&block)
      end

      def handles_event?(event_name)
        event_methods.include? event_name
      end

      private

      def event_methods
        @event_methods ||= []
      end
    end
  end
end
