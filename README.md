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

This gem allows you to specify fields that you want to retrieve from your models and to export them in a csv format.

### Initialization

To initialize the gem usage, loads the GdprExporter module into activerecord classes. Do this at initialization time through an initializer. E.g. create a initializers/gdpr.rb file and add the following:

```ruby
ActiveRecord::Base.send :include, GdprExporter
```

### Data collection

In order to specify the fields you want to return to the user you need to call `gdpr_collect`.
The call target is a rails model and its arguments are:
* a set of simple fields, i.e. fields that will be output as is,
* followed by a hash of params:
```ruby
 {user_id:        <the field in the model used as alias for the user_id field>
  renamed_fields: {<field_from_db> => <field_name_in_output>}
  table_name:     <the new table name in output>
  description:    <a comment>
  joins:           [<an array of associations>]}
```
When `joins` is specified, the fields of an association should be defined as `<association_name> <field_name>`.

#### Example

```ruby
User.gdpr_collect :email, :last_sign_in_at, :type, :forward_mailbox,
                  "program title",
                  {user_id: :id,
                   renamed_fields: {sign_in_count: "sign in count",
                                    current_sign_in_at: "time of current sign in",
                                    chosen_program_id: "chosen program",
                                    current_sign_in_ip: "current IP address",
                                    last_sign_in_ip: "previously used IP address"},
                   joins:          [:program]}
```

From your `User` model, you want to retrieve the values of the fields `email, last_sign_in_at,
type, forward_mailbox`, in addition to the fields `sign_in_count, current_sign_in_at, chosen_program_id, current_sign_in_ip, last_sign_in_ip`. However for the latter you want their csv header to be renamed. And the field representing the user in the `User` model is `id`.
`User` has also an association with `program` and you want to value of its field `title`.

### Data export
Finally, call `GdprExporter.export(<user_id>)` to return a csv formatted output of all the fields you specified previously.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/epfl-exts/rails-gdpr-export.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
