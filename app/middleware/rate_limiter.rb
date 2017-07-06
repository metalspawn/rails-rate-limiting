# This is a very elementary rate limiting class to be used
# as Rack middleware for limiting requests by IP.#
class RateLimiter

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

  def respond_rate_limited(env)
    [429, {}, ["Rate limit exceeded. Try again in #{env['rate_limiter.remaining_time']} seconds"]]
  end

  class << self; attr_accessor :whitelist end
  def whitelisted?(req)
    self.class.whitelist.include?(req.ip)
  end

  class << self; attr_accessor :limit end
  class << self; attr_accessor :period end
  def self.register_limit(limit, period)
    self.limit = limit
    self.period = period.to_i
  end

  def rate_limited?(req)
    count(req) > self.class.limit
  end

  def count(req)
    # Use key-base cache expiration
    period = self.class.period
    now = Time.now.to_i
    time_key = now / period # Key is the nth number of periods since the epoch
    expires_in = (period - (now % period)) # Subtract the remaining seconds from the period
    cache_key = "#{req.ip}-count::#{time_key}"
    req.env['rate_limiter.remaining_time'] = expires_in
    Rails.cache.increment(cache_key, 1, expires_in: expires_in)
  end
end
