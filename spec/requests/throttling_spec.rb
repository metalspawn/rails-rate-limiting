require 'rails_helper'

RSpec.describe "Rate limiter", type: :request do
  include Rack::Test::Methods
  before(:each) { Rails.cache.clear } # Clear cache to avoid conflicting test state

  describe "doesn't throttle within limit" do
    before { 100.times{ get '/', {}, 'REMOTE_ADDR' => '1.2.3.4' } }

    it { expect(last_response.status).to eq(200) }
    it { expect(last_response.body).to match("Ok") }
  end

  describe "throttles after 100 requests from the same IP within the hour" do
    before { 101.times{ get '/', {}, 'REMOTE_ADDR' => '1.2.3.4' } }

    it { expect(last_response.status).to eq(429) }
    it { expect(last_response.body).to include("Rate limit exceeded") }
  end

end
