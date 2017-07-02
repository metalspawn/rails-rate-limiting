RSpec::Matchers.define :show_allowed_response do
  match do |response|
    response.body == 'Ok' && response.status == 200
  end

  failure_message do
    'expected response to return the allowed response'
  end

  failure_message_when_negated do
    'expected response not to return the allowed response'
  end

  description do
    'expected the allowed response'
  end
end

RSpec::Matchers.define :show_throttled_response do
  match do |response|
    response.body.include?('Rate limit exceeded') && response.status == 429
  end

  failure_message do
    'expected response to return the throttled response'
  end

  failure_message_when_negated do
    'expected response not to return the throttled response'
  end

  description do
    'expected the throttled response'
  end
end
