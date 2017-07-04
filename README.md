# Rails Rate Limiting
This is a simple example of adding rate limiting to rails project. There are numerous areas for customisation depending on what the ultimate use case is. The project serves to demonstrate some of those possibilities and provide a base from which to develop further.

# Installation
This project uses Rails 5 and Ruby 2.3.3. See the [Gemfile](https://github.com/metalspawn/rails-rate-limiting/blob/master/Gemfile) for more info.  You will need to install or have access to a Redis database for caching, the connection is configured via a .env file. See [.env.example](https://github.com/metalspawn/rails-rate-limiting/blob/master/.env.example).

# Tests
The project uses Rspec for the test suite. Please run `rspec` from the command line once all the gems are installed and Redis configured to see the test results.

# Stylistic Notes
There was a decision to be made about the identity of the user. In this case I have chosen IP address but if it were for an API for instance, an identifying user property in the request header would be more useful. The solution present can facilitate this will little work.

The project spec also called for 'rate limiting on this controller', referring to the home controller. This implementation limits requests to the whole app (and therefore that controller) but could easily be configured to rate limit on a subset of paths.

These customisations were part of the criteria for selecting a library to use, basic notes on that research can be found here: https://github.com/metalspawn/rails-rate-limiting/issues/4

There are also excessive comments left from the rails default project generation scripts. For a 'production' quality project I would usually clean this up, including extra gems (sqllite is not being used for instance) but I suspect the point of the task was centred around the coding decisions and the testing of the rate limiter.
