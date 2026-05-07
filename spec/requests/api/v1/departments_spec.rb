require "rails_helper"

RSpec.describe "Api::V1::Departments", type: :request do
  describe "GET /api/v1/departments" do
    it "lists departments as JSON objects" do
      create(:department, name: "Alpha Unit")
      create(:department, name: "Beta Unit")

      get "/api/v1/departments"

      expect(response).to have_http_status(:ok)
      rows = response.parsed_body
      expect(rows).to be_an(Array)
      expect(rows.first.keys).to include("id", "name")
      names = rows.map { |r| r["name"] }
      expect(names).to include("Alpha Unit", "Beta Unit")
    end
  end
end
