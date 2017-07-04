class Rack::Attack

  ### Configure Cache ###
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store
  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.cache.store = Rails.cache

  # Throttle all requests by IP (100rph)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 100, period: 1.hour) do |req|
    req.ip # unless req.path.start_with?('/assets')
  end

  # Split list of whitelisted ips
  whitelist = (ENV['RATE_LIMIT_WHITELIST'] || '').split(/,\s*/)
  # Allow requests from whitelist
  safelist('allow from whitelist') do |req|
    # Requests are allowed if the return value is truthy
    whitelist.include?(req.ip)
  end

  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']
    limit_reset = (now + (match_data[:period] - now.to_i % match_data[:period]))
    diff = limit_reset.minus_with_coercion(now).round
    [429, {}, ["Rate limit exceeded. Try again in #{diff} seconds"]]
  end
end
