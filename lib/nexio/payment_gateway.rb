# frozen_string_literal: true

module Nexio
  DEFAULT_CONFIG = {
    "data" => {
      "currency" => "USD",
      "card" => {
        "cardHolderName" => ""
      },
      "customer" => {
        "customerRef" => ""
      }
    },
    "processingOptions" => {
      "checkFraud" => true,
      "verboseResponse" => false,
      "verifyAvs" => 0,
      "verifyCvc" => false
    },
    "shouldUpdateCard" => true,
    "uiOptions" => {
      "displaySubmitButton" => false,
      "hideBilling" => {
        "hideAddressOne" => false,
        "hideAddressTwo" => false,
        "hideCity" => false,
        "hideCountry" => false,
        "hidePostal" => false,
        "hidePhone" => true,
        "hideState" => false
      },
      "hideCvc" => false,
      "requireCvc" => true,
      "forceExpirationSelection" => true
    }
  }.freeze

  class PaymentGateway
    # Creates a card token based on the configuration
    def self.create_one_time_token(config={})
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/token")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = Nexio::DEFAULT_CONFIG.merge(config).to_json
      response = http.request(@request)
      response_or_raise_error(response)
    end

    # {
    #    "card" => {
    #      "cardHolderName" => "Abdul Barek",
    #      "expirationMonth" => "10",
    #      "expirationYear" => "#{Date.today.year + 10}",
    #      "encryptedNumber" => "JQ2DIwFqQOCypsOE+3n0Mx6W6das1LrFAQVFR1lBD9KySCbVQXvJoweQ7R3wCv34oK6d8QlYQgsAWpmcROiwe4LowQI3pLfADmGRg4arowdaW8UBcR3gm26tT7KUdG13Y+0aiTKSleSJiRUSm3yU/VrNMe1tblYG+SsmtC8c3PEZkQxkJ216RYCzBkFRku2O7TRvx/GtxGd4VQItIF567VanRmZ8tIUaZGg9ZN6PKzUifRfCCt+2XGY7I1+Z7EOEAX1gQZT86+2vzcdk8MiZtMS4KYs+4kngSxR2EhyJa+3wRQBmkApRt03qCoWJEPIbNYxgwdjapy2oWeI/DrZu6A=="
    #    },
    #    "data" => {
    #      "currency" => "USD"
    #    },
    #    "shouldUpdateCard" => true,
    #    "token" => @nexio_one_time_token
    # }
    def self.save_card(card={})
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/saveCard")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = card.to_json
      response = http.request(@request)
      response_or_raise_error(response)
    end

    # Deletes card tokens, tokens can be an array
    def self.delete_card(card_tokens=[])
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/deleteToken")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = {
        "tokens" => card_tokens
      }.to_json
      response = http.request(request)
      response_or_raise_error(response)
    end

    # Returns details of a card accepting a card token
    def self.card_token(token)
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/vault/card/#{token}")
      @request = Net::HTTP::Get.new(url)
      http, request = configure_https_request(url, @request)
      response = http.request(request)
      response_or_raise_error(response)
    end

    # Updates cards while accepting card token with new data
    # data = {
    #     "shouldUpdateCard" => true,
    #     "card" => {
    #       "expirationYear" => 2036,
    #       "cardHolderName" => "Abdul Barek",
    #       "expirationMonth" => 3
    #     },
    #     "data" => {
    #       "customer" => {
    #         "billToAddressOne" => "1234 Anywhere St.",
    #         "billToAddressTwo" => "",
    #         "billToPostal" => 84072,
    #         "billToState" => FL,
    #         "billToCity" => "",
    #       }
    #     },
    #   }
    def self.update_card(token, data={})
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/vault/card/#{token}")
      @request = Net::HTTP::Put.new(url)
      http, request = configure_https_request(url, @request)
      request.body = data.to_json
      response = http.request(request)
      response_or_raise_error(response)
    end

    # Makes a charge of a given card using the associated card token
    def self.charge(amount=0, card_token, customer, processingOptions)
      processingOptions = {} if !defined?(processingOptions) || processingOptions.nil? || processingOptions.empty?
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/process")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = {
        "data" => {
          "currency" => "USD", "amount" => amount,
          "customer" => {
            "customerRef" => customer["customerRef"],
            "orderNumber" => customer["orderNumber"],
          },
        },
        "tokenex" => {"token" => card_token},
        "processingOptions" =>
          {
            "paymentType" => processingOptions["paymentType"],
            "retryOnSoftDecline" => false,
            "checkFraud" => true,
            "shouldUseFingerprint" => true,
            "check3ds" => false,
            "verboseResponse" => false
          }.merge(processingOptions),
        "shouldUpdateCard" => true,
        "isAuthOnly" => false,
        "paymentMethod" => "card"
      }.to_json
      response = http.request(request)
      response_or_raise_error(response)
    end

    # Amount is in USD
    def self.refund(nexio_payment_id, amount)
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/refund")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = {
        "id" => nexio_payment_id,
        "data" => {
          "currency" => "USD", "amount" => amount
        },
      }.to_json
      response = http.request(request)
      response_or_raise_error(response)
    end

    def self.payment_status(nexio_payment_id)
      url = URI("#{Nexio.configuration.api_server_url}/transaction/v3/paymentId/#{nexio_payment_id}")
      @request = Net::HTTP::Get.new(url)
      http, request = configure_https_request(url, @request)
      response = http.request(request)
      response_or_raise_error(response)
    end

    def self.void_payment(nexio_payment_id)
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/void")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = {
        "id" => nexio_payment_id
      }.to_json
      response = http.request(request)
      response_or_raise_error(response)
    end

    # https configuration using base64 basic auth code
    def self.configure_https_request(url, request)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request["accept"] = "application/json"
      request["content-type"] = "application/json"
      request["authorization"] = "Basic #{Nexio.configuration.api_key!}"
      [http, request]
    end

    def self.response_or_raise_error(response)
      if response.code.to_s == '200'
        JSON.parse(response.read_body)
      else
        request_details = {
          headers: @request.each_header.to_h,
          url: @request.uri.to_s,
          method: @request.method,
          query_string: @request.uri.query,
          body: @request.body
        }
        response_body = JSON.parse(response.read_body) rescue {}
        raise Nexio::NexioError.new(response_body, request_details)
      end
    end

  end
end
