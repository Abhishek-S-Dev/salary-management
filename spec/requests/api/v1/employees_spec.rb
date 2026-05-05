require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  describe "GET /api/v1/employees" do
    it "returns employees as JSON" do
      create(:employee, first_name: "Ada", last_name: "Lovelace")

      get "/api/v1/employees"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to be_an(Array)
      expect(body.first["first_name"]).to eq("Ada")
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
