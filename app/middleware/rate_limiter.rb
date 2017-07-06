class RateLimiter
  def initialize(app)
    @app = app
  end

  def call(env)
    if whitelisted?(env)
      @app.call(env)
    elsif rate_limited?(env)
      respond_rate_limited(env)
    else
      @app.call(env)
    end
  end

  def respond_rate_limited(env)
    [429, {}, ['Rate limit exceeded. Try again in [n] seconds']]
  end

  def whitelisted?(env)
    false
  end

  def rate_limited?(env)
    true
  end
end
