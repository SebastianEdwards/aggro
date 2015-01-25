module Aggro
  # Public: Adds a DSL creating domain event bindings.
  module BindingDSL
    def bind(ref, filters: default_filters, to: nil, &block)
      if to
        bindings << Aggro.event_bus.subscribe(ref.id, self, to, filters)
      else
        bind_block ref, filters, &block
      end
    end

    def handles_event?(event_name, namespace = nil)
      event_methods[namespace].include? event_name
    end

    private

    def bind_block(ref, filters, namespace = generate_namespace, &block)
      new_methods = BlockHelper.method_definitions(&block)
      event_methods[namespace] = Set.new(new_methods)

      class_eval(&block)
      move_methods_to_namespace(new_methods, namespace)

      bindings << Aggro.event_bus.subscribe(ref.id, self, namespace, filters)
    end

    def bindings
      @bindings ||= []
    end

    def default_filters
      {}
    end

    def event_methods
      @event_methods ||= {}
    end

    def generate_namespace
      [*('a'..'z')].sample(8).join
    end

    def move_methods_to_namespace(method_list, namespace)
      class_eval do
        method_list.each do |method|
          alias_method "#{namespace}_#{method}", method
          remove_method method
        end
      end
    end
  end
end
