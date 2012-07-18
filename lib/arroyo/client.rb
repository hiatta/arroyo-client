module Arroyo
  module Client
    extend self

    def in_parallel(&block)
      return yield unless config[:adapter] == :typhoeus

      manager = Typhoeus::Hydra.new(:max_concurrency => 10)
      connection.in_parallel(manager, &block)
    end

  private

    def connection
      @connection ||= Faraday.new(url: config[:host]) do |b|
        b.adapter *config[:adapter]
      end
    end
  end
end
