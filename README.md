# rails-gdpr-export

A gem for exporting user personal data in compliance with GDPR.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-gdpr-export'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-gdpr-export

## Usage

- Add the following code in a initializer file (e.g. initializers/gdpr.rb):

```ruby
require 'exts/gdpr'

# Loads the Gdpr module into activerecord classes.
ActiveRecord::Base.send :include, Gdpr


# Defines gdpr data collection throughout the model classes
#
User.gdpr_collect :email, :last_sign_in_at, :stripe_customer_id,
                  :type, :forward_mailbox,
                  {user_id: :id,
                   renamed_fields: {sign_in_count: "sign in count",
                                    current_sign_in_at: "time of current sign in",
                                    chosen_program_id: "chosen program",
                                    current_sign_in_ip: "current IP address",
                                    last_sign_in_ip: "previously used IP address"}}


Subscription.gdpr_collect  :stripe_id, :stripe_plan_id,
                           :exmatriculated_at, :current_period_end, :status,
                           :notified_at, :pause_reason, :pause_error,
                           :start_at, :initial_start_at, :completed_at,
                           :amount, :paused_at, :rules_accepted_at,
                           {user_id: :user_id,
                            join: :program,
                            renamed_fields: {title: "program title"}}
```

- call Gdpr.export(<user_id>) and it will return a csv formatted output

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-gdpr-export.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
