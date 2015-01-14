module Aggro
  module Message
    # Public: Command message.
    class Command < Struct.new(:sender, :commandee_id)
      def self.parse(string)
        new string[1..36], string[37..74]
      end
    end
  end
end
