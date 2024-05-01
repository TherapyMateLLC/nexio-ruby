# frozen_string_literal: true
require "test_helper"
require 'vcr'
require "support/vcr_setup"

class TestNexio < Minitest::Test

  def setup
    Nexio.configure do |config|
      config.api_key = "YmFyZWsyazJAZ21haWwuY29tOjExMTExMTExMTExMTExYUE="
      config.environment = "test"
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
            # original card number is 5105105105105100
            "encryptedNumber" => "NfveoPT0AyDMQtGqITRAjRnQmcbnlnMCg36UMSj4OFa8ZIvtz+3TML6hkEpFPXCk9/u5X/Qoj/9RIFfmdSmKZ83q/2tD5md76pjic7K4Gsz97w668rxiNFOuMn1eQWqReU2+6e8QvYbo4+3pXquXOdAuZyykwp+V2FvWmaE/Z/IX5K9MZuhJWX6ANts8FcwC98JTDPuD9hWRY1vyGs36XrvOMfrT3yLiZQrBd0Syib3F/PRPWZdJMQBQaFwI4gAM30vi5HlV3aB+DzsG31t52R9I1Ci0tH+pYtOpMZEXaPE8bsD8MwYzZcDUQ4V+7ntCOKeYrApD0pqViXSfcpnDfg=="
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
      @charge = Nexio::PaymentGateway.charge(20.49,@card["token"]["token"],{})
    end
    refute_nil @charge["authCode"]
    assert_equal 20.49, @charge["amount"].to_f
  end

  def test_refund
    VCR.use_cassette('save_credit_card') do
      @nexio_one_time_token = create_one_time_token
      @card = Nexio::PaymentGateway.save_card(
        {
          "card" => {
            "cardHolderName" => "Abdul Barek",
            "expirationMonth" => "10",
            "expirationYear" => "#{Date.today.year + 10}",
            # follow this for generating encrypted card number https://jsfiddle.net/nexiopaydev/qkwautgb/30/
            # original card number is 5105105105105100
            # The amount is settled immediately for this card.
            "encryptedNumber" => "NfveoPT0AyDMQtGqITRAjRnQmcbnlnMCg36UMSj4OFa8ZIvtz+3TML6hkEpFPXCk9/u5X/Qoj/9RIFfmdSmKZ83q/2tD5md76pjic7K4Gsz97w668rxiNFOuMn1eQWqReU2+6e8QvYbo4+3pXquXOdAuZyykwp+V2FvWmaE/Z/IX5K9MZuhJWX6ANts8FcwC98JTDPuD9hWRY1vyGs36XrvOMfrT3yLiZQrBd0Syib3F/PRPWZdJMQBQaFwI4gAM30vi5HlV3aB+DzsG31t52R9I1Ci0tH+pYtOpMZEXaPE8bsD8MwYzZcDUQ4V+7ntCOKeYrApD0pqViXSfcpnDfg=="
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
      @charge = Nexio::PaymentGateway.charge(20.49,@card["token"]["token"],{})
      @payment_id = @charge["id"]
    end
    VCR.use_cassette('refund') do
      @refund = Nexio::PaymentGateway.refund(@payment_id,1.20)
      assert_equal "refund",@refund["transactionType"]
      assert_equal -1.20,@refund["amount"]
      refute_nil @refund["authCode"]
    end
  end

  def test_payment_status
    VCR.use_cassette('save_credit_card') do
      @nexio_one_time_token = create_one_time_token
      @card = Nexio::PaymentGateway.save_card(
        {
          "card" => {
            "cardHolderName" => "Abdul Barek",
            "expirationMonth" => "10",
            "expirationYear" => "#{Date.today.year + 10}",
            # follow this for generating encrypted card number https://jsfiddle.net/nexiopaydev/qkwautgb/30/
            # original card number is 5105105105105100
            # The amount is settled immediately for this card.
            "encryptedNumber" => "NfveoPT0AyDMQtGqITRAjRnQmcbnlnMCg36UMSj4OFa8ZIvtz+3TML6hkEpFPXCk9/u5X/Qoj/9RIFfmdSmKZ83q/2tD5md76pjic7K4Gsz97w668rxiNFOuMn1eQWqReU2+6e8QvYbo4+3pXquXOdAuZyykwp+V2FvWmaE/Z/IX5K9MZuhJWX6ANts8FcwC98JTDPuD9hWRY1vyGs36XrvOMfrT3yLiZQrBd0Syib3F/PRPWZdJMQBQaFwI4gAM30vi5HlV3aB+DzsG31t52R9I1Ci0tH+pYtOpMZEXaPE8bsD8MwYzZcDUQ4V+7ntCOKeYrApD0pqViXSfcpnDfg=="
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
      @charge = Nexio::PaymentGateway.charge(20.49,@card["token"]["token"],{})
      @payment_id = @charge["id"]
    end
    VCR.use_cassette('payment_status') do
      @payment_status = Nexio::PaymentGateway.payment_status(@payment_id)
      refute_nil @payment_status["transactionStatus"]
      assert_equal 20, @payment_status["transactionStatus"]
    end
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
