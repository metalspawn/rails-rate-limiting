require 'rails_helper'

RSpec.describe 'Rate limiter', type: :request do
  include Rack::Test::Methods
  before(:each) { Rails.cache.clear } # Clear cache to avoid conflicting test state

  describe 'throttles excessive requests by IP address' do
    before do
      freezed_time = Time.utc(2017, 1, 1, 12, 30, 0)
      Timecop.freeze(freezed_time)
      request_count.times{ get '/', {}, 'REMOTE_ADDR' => ip }
    end

    context 'when the number of requests is lower than the limit' do
      let(:request_count) { 100 }
      let(:ip) { '1.2.3.5' }
      it { expect(last_response).to show_allowed_response }
    end

    context 'when the IP is whitelisted' do
      let(:request_count) { 100 }
      let(:ip) { '1.2.3.4' }
      it { expect(last_response).to show_allowed_response }
    end

    context 'when the number of requests is higher than the limit' do
      let(:request_count) { 101 }
      let(:ip) { '1.2.3.5' }

      it { expect(last_response).to show_throttled_response }

      it 'shows the time remaining in the body' do
        expect(last_response.body).to include('1800')
      end

      it 'does not throttle if a request occurs in the next hour' do
        Timecop.travel(1800.seconds.from_now)
        get '/', {}, 'REMOTE_ADDR' => '1.2.3.5'
        expect(last_response).to show_allowed_response
      end
    end
  end

  describe 'can be configured with different limits' do
    before do
      RateLimiter.register_limit(50, 15.minutes)
      freezed_time = Time.utc(2017, 1, 1, 12, 30, 0)
      Timecop.freeze(freezed_time)
      51.times{ get '/', {}, 'REMOTE_ADDR' => '1.2.3.5' }
    end 

    context 'when limited to 50 request per 15 minutes' do
      it 'throttles when the number of requests when reached' do
        expect(last_response).to show_throttled_response
      end
      it 'does not throttle if a request occurs after 15 minutes' do
        Timecop.travel(900.seconds.from_now)
        get '/', {}, 'REMOTE_ADDR' => '1.2.3.5'
        expect(last_response).to show_allowed_response
      end
    end
  end
end
