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
      #raise Nexio::DEFAULT_CONFIG.merge(config).to_json.inspect
      request.body = Nexio::DEFAULT_CONFIG.merge(config).to_json
      response = http.request(@request)
      JSON.parse(response.read_body)
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
      JSON.parse(response.read_body)
    end

    # Returns details of a card accepting a card token
    def self.card_token(token)
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/vault/card/#{token}")
      @request = Net::HTTP::Get.new(url)
      http, request = configure_https_request(url, @request)
      response = http.request(request)
      JSON.parse(response.read_body)
    end

    # Updates cards while accepting card token with new data
    # data = {
    #     "shouldUpdateCard" => true,
    #     "card" => {
    #       "expirationYear" => 2036,
    #       "cardHolderName" => Abdul Barek,
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
      JSON.parse(response.read_body)
    end

    # Makes a charge of a given card using the associated card token
    def self.charge(amount=0, card_token)
      url = URI("#{Nexio.configuration.api_server_url}/pay/v3/process")
      @request = Net::HTTP::Post.new(url)
      http, request = configure_https_request(url, @request)
      request.body = {
        "data" => {
          "currency" => "USD", "amount" => amount
        },
        "tokenex" => {"token" => card_token},
        "processingOptions" =>
          {
            "retryOnSoftDecline" => false,
            "checkFraud" => true,
            "shouldUseFingerprint" => true,
            "check3ds" => false,
            "verboseResponse" => false
          },
        "shouldUpdateCard" => true,
        "isAuthOnly" => false,
        "paymentMethod" => "card"
      }.to_json
      response = http.request(request)
      JSON.parse(response.read_body)
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
  end
end
