module Aggro
  module Handler
    # Private: Handler for incoming query requests.
    class Query < Struct.new(:message, :server)
      def call
        queryee_local? ? handle_local : handle_foreign
      end

      private

      def channel
        Aggro.channels[queryable_id]
      end

      def query
        @query ||= message.to_query
      end

      def queryable_id
        message.queryable_id
      end

      def query_known?
        !query.nil?
      end

      def queryee_local?
        comandee_locator.local?
      end

      def comandee_locator
        @comandee_locator ||= Locator.new(queryable_id)
      end

      def handle_foreign
        comandee_locator.primary_node.client.post message
      end

      def handle_known
        if channel
          if channel.handles_query?(query)
            handle_supported
          else
            Message::UnhandledOperation.new
          end
        else
          Message::InvalidTarget.new
        end
      end

      def handle_local
        query_known? ? handle_known : handle_unknown
      end

      def handle_unknown
        Message::UnknownOperation.new
      end

      def handle_supported
        result = channel.run_query(query)

        result.wait(5)

        if result.fulfilled?
          Message::Result.new result.value
        else
          Message::Result.new Aggro::QueryError.new('Query timed out')
        end
      end
    end
  end
end
