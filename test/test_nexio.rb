# frozen_string_literal: true
require "test_helper"
require 'vcr'
require "support/vcr_setup"

class TestNexio < Minitest::Test

  def setup
    Nexio.configure do |config|
      config.api_key = "YmFyZWsyazJAZ21haWwuY29tOjExMTExMTExMTExMTExYUE="
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Nexio::VERSION
  end

  def test_create_one_time_token
    VCR.use_cassette('one_time_token') do
      @nexio_one_time_token = Nexio::PaymentGateway.create_one_time_token(
        {
          "card" => {
            "cardHolderName" => "Abdul Barek"
          },
          "data" => {
            "currency" => "USD",
            "customer" => {
              "customerRef" => 48,
              "billToAddressOne" => "Main Stret",
              "billToAddressTwo" => "",
              "billToCity" => "Utah",
              "billToState" => "UT",
              "billToPostal" => "80724",
            }
          }})["token"]
      refute_nil(@nexio_one_time_token)
    end
  end
end
