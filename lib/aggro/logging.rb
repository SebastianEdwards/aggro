require 'logger'

module Aggro
  # Private: Mixin for logging concerns.
  module Logging
    include Logger::Severity

    def log(level, progname, message = nil, &block)
      (@logger || Aggro.logger).call level, progname, message, &block
    rescue => e
      $stderr.puts '`Aggro.logger` failed to log ' \
                   "#{[level, progname, message, block].join(' ')}\n" \
                   "#{e.message} (#{e.class})\n#{e.backtrace.join "\n"}"
    end
  end
end
