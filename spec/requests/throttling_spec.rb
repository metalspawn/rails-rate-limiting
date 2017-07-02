require 'rails_helper'

RSpec.describe 'Rate limiter', type: :request do
  include Rack::Test::Methods
  before(:each) { Rails.cache.clear } # Clear cache to avoid conflicting test state

  describe 'throttles excessive requests by IP address' do
    before do
      freezed_time = Time.utc(2017, 1, 1, 12, 30, 0)
      Timecop.freeze(freezed_time)
      request_count.times{ get '/', {}, 'REMOTE_ADDR' => '1.2.3.4' }
    end

    context 'when the number of requests is lower than the limit' do
      let(:request_count) { 100 }
      it { expect(last_response).to show_allowed_response }
    end

    context 'when the number of requests is higher than the limit' do
      let(:request_count) { 101 }

      it { expect(last_response).to show_throttled_response }

      it 'shows the time remaining in the body' do
        expect(last_response.body).to include('1800')
      end

      it 'does not throttle if a request occurs in the next hour' do
        Timecop.travel(1800.seconds.from_now)
        get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'
        expect(last_response).to show_allowed_response
      end
    end
  end
end
