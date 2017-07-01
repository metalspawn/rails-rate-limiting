require 'rails_helper'

RSpec.describe 'Root path', type: :request do
  describe 'GET /' do
    before { get '/' }

    it { expect(response).to have_http_status(:ok) }

    it { expect(response.body).to match('Ok') }
  end
end
