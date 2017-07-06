RateLimiter.whitelist = (ENV['RATE_LIMIT_WHITELIST'] || '').split(/,\s*/)
RateLimiter.register_limit(100, 1.hour)
