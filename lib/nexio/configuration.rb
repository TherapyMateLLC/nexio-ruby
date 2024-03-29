# frozen_string_literal: true

module Nexio
  class Configuration
    DEFAULTS = {
      "sandbox_url" => "https://api.nexiopaysandbox.com",
      "production_url" => "https://api.nexiopay.com",
    }.freeze

    attr_accessor :api_key, :environment

    attr_writer :api_server_url

    def initialize
      @api_server_url = nil
    end

    def api_key!
      api_key || raise(NexioError, "No api key specified.")
    end

    def api_server_url
      @api_server_url || (environment == "production" ? DEFAULTS.fetch("production_url") : DEFAULTS.fetch("sandbox_url"))
    end
  end
end
