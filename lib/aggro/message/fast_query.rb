require_relative './query'

module Aggro
  module Message
    # Public: Query message.
    class FastQuery < Query
      TYPE_CODE = '16'.freeze
    end
  end
end
