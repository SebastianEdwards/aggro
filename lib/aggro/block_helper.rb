module Aggro
  # Private: Helper fuction for common operations on blocks.
  module BlockHelper
    module_function

    def method_definitions(&block)
      test_class = Class.new(BasicObject)
      starting_methods = test_class.instance_methods
      test_class.class_eval(&block)

      test_class.instance_methods - starting_methods
    end
  end
end
