##
# This is a very elementary rate limiting class to be used
# as Rack middleware for limiting requests by IP.
#
# Features:
# * Stores entries in the configured Rails.cache
# * Use RateLimiter.whitelist = ['1.2.3.4', ...] to
# * Use RateLimiter.register_limit to adjust throttling limits
##
class RateLimiter

  class << self
    attr_accessor :whitelist
    attr_accessor :limit
    attr_accessor :period

    def register_limit(limit, period)
      self.limit = limit
      self.period = period.to_i
    end
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    if whitelisted?(req)
      @app.call(env)
    elsif rate_limited?(req)
      respond_rate_limited(env)
    else
      @app.call(env)
    end
  end

  def whitelisted?(req)
    whitelist && whitelist.include?(req.ip)
  end

  def rate_limited?(req)
    if limit && period
      count(req) > limit
    else
      false
    end
  end

  def count(req)
    # Use key-base cache expiration
    now = Time.now.to_i
    time_key = now / period # nth number of periods since the epoch
    expires_in = (period - (now % period)) # Determine the remaining seconds for the period
    cache_key = "#{req.ip}-count::#{time_key}"
    req.env['rate_limiter.remaining_time'] = expires_in
    Rails.cache.increment(cache_key, 1, expires_in: expires_in)
  end

  def respond_rate_limited(env)
    [429, {}, ["Rate limit exceeded. Try again in #{env['rate_limiter.remaining_time']} seconds"]]
  end

  # Class instance variable helper accessors
  def limit
    self.class.limit
  end

  def period
    self.class.period
  end

  def whitelist
    self.class.whitelist
  end
end
