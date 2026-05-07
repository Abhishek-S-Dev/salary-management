require "rails_helper"

RSpec.describe "Api::V1::Health", type: :request do
  describe "GET /api/v1/health" do
    it "reports database connectivity" do
      get "/api/v1/health"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["ok"]).to be(true)
      expect(body["database"]).to eq("connected")
    end
  end
end
