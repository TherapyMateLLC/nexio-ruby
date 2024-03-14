# Nexio

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nexio`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

**Configuration**
```
  Nexio.configure do |config|
    config.api_key = <YOUR_NEXIO_API_KEY>
  end
```

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
      "cardHolderName" => Abdul Barek,
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
```
amount_in_usd = 20.25
Nexio::PaymentGateway.charge(amount_in_usd,card_token)
```

**Handling error**
```
begin
  Nexio::PaymentGateway.charge(10.60,'kola')
rescue Nexio::NexioError => e
  puts e.to_hash
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nexio.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
