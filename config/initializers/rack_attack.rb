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

  # Allow requests from localhost to avoid developer related problems
  # Want to add this to .env to assist any custom clients or issues with staging testing etc.
  safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']
    limit_reset = (now + (match_data[:period] - now.to_i % match_data[:period]))
    diff = limit_reset.minus_with_coercion(now).round
    [429, {}, ["Rate limit exceeded. Try again in #{diff} seconds"]]
  end
  # Rack::Attack.throttled_response = ->(env) { [429, {}, [ActionView::Base.new.render(file: 'public/429.html')]] }
end