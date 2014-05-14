knife-cs
========

Knife Cloudstack Plugin

This plugin is a rewrite of the knife-cloudstack plugin based on the knife-cloud framework.

With this plugin we try to achieve the following goals:

- Use the fog framework to reduce code duplication.
- Use the knife-cloud framework to reduce code duplication.
- Write tests for every plugin command.

Ultimate goal is to replace the following plugins and combine them into knife-cs.

- https://github.com/CloudStack-extras/knife-cloudstack
- https://github.com/fifthecho/knife-cloudstack-fog

## Installation

Add this line to your application's Gemfile:

    gem 'knife-cs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-cs

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/knife-cloudstack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
