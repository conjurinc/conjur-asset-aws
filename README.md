# Conjur::Asset::AWS

Conjur plugin for integrating with AWS. This plugin will upload a host factory token to Amazon S3 and create a new IAM role with `read` permission on the token, allowing you to launch instances that access the token at launch time.

## Installation
#### For Development
Add this line to your application's Gemfile:

```ruby
gem 'conjur-asset-aws'
```

And then execute:

    $ bundle
    
Or install it yourself as:

    $ gem install conjur-asset-aws

#### As a Conjur CLI Plugin
Using the Conjur CLI:

    $ conjur plugin install aws
## Usage

#### Creating a Token Link
Before beginning, make sure you've [set up your AWS credentials](http://docs.aws.amazon.com/AWSSdkDocsRuby/latest//DeveloperGuide/set-up-creds.html).

Next, you'll need a token from a host factory.

If you have a host factory with an **existing token**, you can view the token as follows:

    $ conjur hostfactory show prod/bastion/v1/factory
    {
      "id": "prod/bastion/v1/factory",
      "layers": [
        "prod/bastion/v1"
      ],
      "roleid": "dev:policy:prod/bastion/v1",
      "resourceid": "dev:host_factory:prod/bastion/v1/factory",
      "tokens": [
        {
          "token": "e6p1y91pd1d632s0rcq0321td923hrk45b3d5cy0cf06pvdm2gh8g",
          "expiration": "2015-11-17T19:17:33Z"
        }
      ],
      "deputy_api_key": "26bv56a31qh44x1wfm9871xhmjf42s53b692bbfke22yatjew2tymtgq"
    }

If you don't yet have an existing token, you may **create a new host factory token**:

    $ conjur hostfactory tokens create prod/bastion/v1/factory
    [
      {
        "token": "e6p1y91pd1d632s0rcq0321td923hrk45b3d5cy0cf06pvdm2gh8g",
        "expiration": "2015-11-17T19:17:33+00:00"
      }
    ]
    
The token we will be using from here on out can be found in the "token" JSON field in both of the above examples.

Create a token link, making sure to replace the value of the `--bucket` parameter with your own bucket in Amazon S3:

    $ conjur aws token-link create --bucket my-enterprise-hosts --host-factory-token e6p1y91pd1d632s0rcq0321td923hrk45b3d5cy0cf06pvdm2gh8g
    Created Conjur IAM link prod-bastion-v1-factory

After successfully running this command there should be a file in the bucket you've specified named after the host factory which owns the token, containing the value of the token.

#### Deleting a Token Link
To delete the token link, specify the bucket containing the token link as well as the host factory you wish to remove links from (this will remove the data from S3):
    
    $ conjur aws token-link delete --bucket my-enterprise-hosts --host-factory=prod/bastion/v1/factory
    Deleted Conjur IAM link prod-bastion-v1-factory
    
## Contributing

1. Fork it ( https://github.com/[my-github-username]/conjur-asset-aws/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
