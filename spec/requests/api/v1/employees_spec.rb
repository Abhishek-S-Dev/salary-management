require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  describe "GET /api/v1/employees" do
    it "returns a paginated envelope with meta" do
      create(:employee, first_name: "Ada", last_name: "Lovelace")

      get "/api/v1/employees"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"]).to be_an(Array)
      expect(body["data"].first["first_name"]).to eq("Ada")
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => 20,
        "total_count" => 1,
        "total_pages" => 1
      )
    end

    it "paginates using page and per_page" do
      21.times { create(:employee) }

      get "/api/v1/employees", params: { page: 2, per_page: 10 }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].size).to eq(10)
      expect(body["meta"]["page"]).to eq(2)
      expect(body["meta"]["per_page"]).to eq(10)
      expect(body["meta"]["total_count"]).to eq(21)
      expect(body["meta"]["total_pages"]).to eq(3)
    end

    it "filters employees when q matches name or email" do
      create(:employee, first_name: "Zara", last_name: "Amin", email: "zara@example.com")
      create(:employee, first_name: "Bob", last_name: "Builder", email: "bob@example.com")

      get "/api/v1/employees", params: { q: "zara" }

      expect(response).to have_http_status(:ok)
      data = response.parsed_body["data"]
      expect(data.size).to eq(1)
      expect(data.first["email"]).to eq("zara@example.com")

      get "/api/v1/employees", params: { q: "bob@example" }

      expect(response.parsed_body["data"].size).to eq(1)
    end
  end

  describe "POST /api/v1/employees" do
    let(:params) do
      {
        employee: {
          first_name: "Alan",
          last_name: "Turing",
          email: "alan@example.com",
          department: "Research",
          designation: "Scientist",
          base_salary: 90_000
        }
      }
    end

    it "creates an employee" do
      expect do
        post "/api/v1/employees", params: params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
      end.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["email"]).to eq("alan@example.com")
    end

    it "returns errors when invalid" do
      post "/api/v1/employees",
           params: { employee: { first_name: "", last_name: "", email: "bad", base_salary: -1 } }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    it "removes the employee" do
      employee = create(:employee)

      expect do
        delete "/api/v1/employees/#{employee.id}"
      end.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
