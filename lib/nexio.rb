# frozen_string_literal: true

require "uri"
require "net/http"

require "nexio/version"
require "nexio/configuration"
require "nexio/payment_gateway"

module Nexio
  class NexioError < StandardError
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    config = configuration
    yield(config)
  end

  def self.api_server_url
    configuration.api_server_url
  end
end
