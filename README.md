# Nexio

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nexio

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nexio

## Usage

**Configuration**
```
  Nexio.configure do |config|
    config.api_key = <YOUR_NEXIO_API_KEY>
    config.environment = "development"
  end
```
Setting `config.environment` to `development` will use sandbox, otherwise it will use live Nexio API.

**Creating One Time Token**
```
@nexio_one_time_token = Nexio::PaymentGateway.create_one_time_token(
  {
    "card" => {
      "cardHolderName" => "Abdul Barek"
    },
  "data" => {
  "currency" => "USD",
  "customer" => {
    "customerRef" => 780,
    "billToAddressOne" => "Main Road",
    "billToAddressTwo" => "",
    "billToCity" => "Same City",
    "billToState" => "FL",
    "billToPostal" => "84702",
  }
}})["token"]
```

**Update a card**
```
 data = {
    "shouldUpdateCard" => true,
    "card" => {
      "expirationYear" => 2036,
      "cardHolderName" => "Abdul Barek",
      "expirationMonth" => 3
    },
    "data" => {
      "customer" => {
        "billToAddressOne" => "1234 Anywhere St.",
        "billToAddressTwo" => "",
        "billToPostal" => 84072,
        "billToState" => FL,
        "billToCity" => "",
      }
    },
  }
Nexio::PaymentGateway.update_card(<CARD_TOKEN>, data)
```

**Deleting Cards**

```
Nexio::PaymentGateway.delete_card([card_token1, card_token2])
```

**Retrieving details of card**
```
Nexio::PaymentGateway.card_token(card_token)
```

**Saving a credit card**
```
@card = Nexio::PaymentGateway.save_card(
    {
      "card" => {
        "cardHolderName" => "Abdul Barek",
        "expirationMonth" => "10",
        "expirationYear" => "#{Date.today.year + 10}",
        "encryptedNumber" => "JQ2DIwFqQOCypsOE+3n0Mx6W6das1LrFAQVFR1lBD9KySCbVQXvJoweQ7R3wCv34oK6d8QlYQgsAWpmcROiwe4LowQI3pLfADmGRg4arowdaW8UBcR3gm26tT7KUdG13Y+0aiTKSleSJiRUSm3yU/VrNMe1tblYG+SsmtC8c3PEZkQxkJ216RYCzBkFRku2O7TRvx/GtxGd4VQItIF567VanRmZ8tIUaZGg9ZN6PKzUifRfCCt+2XGY7I1+Z7EOEAX1gQZT86+2vzcdk8MiZtMS4KYs+4kngSxR2EhyJa+3wRQBmkApRt03qCoWJEPIbNYxgwdjapy2oWeI/DrZu6A=="
      },
      "data" => {
        "currency" => "USD"
      },
      "shouldUpdateCard" => true,
      "token" => <ONE_TIME_TOKEN>
    }
  )
```

**Charging a card through it's token**

It is highly recommended to pass order number and customer reference on charging a credit card.

```
customer = {
  "orderNumber" => 4848,
  "customerRef" => 123
}
amount_in_usd = 20.25
Nexio::PaymentGateway.charge(amount_in_usd,card_token, customer)
```

**Way to refund**
```
@refund = Nexio::PaymentGateway.refund(@nexio_payment_id,1.20)
```
You can use card `5105105105105100` to charge and refund for testing purpose as it settles payment immediately.

**Handling error**
```
begin
  Nexio::PaymentGateway.charge(10.60,'invalid_card_token')
rescue Nexio::NexioError => e
  puts e.to_hash
end
```

**Getting http request details including body parameters and header information**
```
begin
  Nexio::PaymentGateway.charge(10.60,'invalid_card_token')
rescue Nexio::NexioError => e
  puts e.request_details_in_hash
end
```

**How to use custom css**

This is very easy to style payment form by passing css file in `uiOptions` as below:
```
@nexio_one_time_token = Nexio::PaymentGateway.create_one_time_token(
      {
        "card" => {},
        "uiOptions" => {
          "css" => ActionController::Base.helpers.asset_path('your_custom.css', host: Rails.application.secrets.asset_host ? Rails.application.secrets.asset_host : request.base_url)
        },
      "data" => {
      "currency" => "USD",
      "customer" => {}
    }})["token"]
```
Sample CSS: Nexio payment form has a wrapper with `#paymentForm` element, so you can apply more
css considering it as parent. Just inspect the Nexio payment form to get their DOM structure in order
to apply styles. SCSS Example:
```
#paymentForm{
  width: 500px;
  margin-left: 180px;
  #cardHolderName{}
  #securityCode{}
}
```

## Testing
`bundle exec rake test`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nexio.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
