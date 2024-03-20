# frozen_string_literal: true

require "uri"
require "net/http"

require "nexio/version"
require "nexio/configuration"
require "nexio/payment_gateway"

module Nexio
  class NexioError < StandardError
    attr_accessor :errors
    attr_accessor :request_details
    def initialize(msg = nil, request_details)
      @errors = msg || {}
      @request_details = request_details || {}
    end
    def to_hash
      @errors
    end
    def request_details_in_hash
      @request_details
    end
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
