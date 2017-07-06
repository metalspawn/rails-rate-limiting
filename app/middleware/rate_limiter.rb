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
    [429, {}, ['Rate limit exceeded. Try again in [n] seconds']]
  end

  class << self; attr_accessor :whitelist end
  def whitelisted?(req)
    self.class.whitelist.include?(req.ip)
  end

  def rate_limited?(req)
    true
    # rate_limiting_rules.any?{|rule| rule.match?(env)}
  end
end
