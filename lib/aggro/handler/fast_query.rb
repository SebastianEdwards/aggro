require_relative './query'

module Aggro
  module Handler
    # Private: Handler for incoming query requests.
    class FastQuery < Query
      def handle_supported
        Message::Result.new channel.run_fast_query(query)
      end
    end
  end
end
