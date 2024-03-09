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
    @nexio_one_time_token = create_one_time_token
    refute_nil(@nexio_one_time_token)
  end

  def test_save_credit_card_and_charge
    VCR.use_cassette('save_credit_card') do
      @nexio_one_time_token = create_one_time_token
      @card = Nexio::PaymentGateway.save_card(
        {
          "card" => {
            "cardHolderName" => "Abdul Barek",
            "expirationMonth" => "10",
            "expirationYear" => "#{Date.today.year + 10}",
            # follow this for generating encrypted card number https://jsfiddle.net/nexiopaydev/qkwautgb/30/
            # original card number is 4000200011112222
            "encryptedNumber" => "JQ2DIwFqQOCypsOE+3n0Mx6W6das1LrFAQVFR1lBD9KySCbVQXvJoweQ7R3wCv34oK6d8QlYQgsAWpmcROiwe4LowQI3pLfADmGRg4arowdaW8UBcR3gm26tT7KUdG13Y+0aiTKSleSJiRUSm3yU/VrNMe1tblYG+SsmtC8c3PEZkQxkJ216RYCzBkFRku2O7TRvx/GtxGd4VQItIF567VanRmZ8tIUaZGg9ZN6PKzUifRfCCt+2XGY7I1+Z7EOEAX1gQZT86+2vzcdk8MiZtMS4KYs+4kngSxR2EhyJa+3wRQBmkApRt03qCoWJEPIbNYxgwdjapy2oWeI/DrZu6A=="
          },
          "data" => {
            "currency" => "USD"
          },
          "shouldUpdateCard" => true,
          "token" => @nexio_one_time_token
        }
      )
    end

    VCR.use_cassette('charge_credit_card') do
      @charge = Nexio::PaymentGateway.charge(20.49,@card["token"]["token"])
    end
    refute_nil @charge["authCode"]
    assert_equal 20.49, @charge["amount"].to_f
  end

  private
  def create_one_time_token
    VCR.use_cassette('one_time_token') do
      @nexio_one_time_token = Nexio::PaymentGateway.create_one_time_token(
        {
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
    end
    @nexio_one_time_token
  end

end
