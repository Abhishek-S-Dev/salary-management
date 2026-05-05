require "rails_helper"

RSpec.describe "Api::V1::PayrollEntries", type: :request do
  let(:employee) { create(:employee) }

  describe "GET /api/v1/employees/:employee_id/payroll_entries" do
    it "returns payroll entries for the employee" do
      create(:payroll_entry, employee: employee, period_year: 2026, period_month: 3)

      get "/api/v1/employees/#{employee.id}/payroll_entries"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.size).to eq(1)
      expect(response.parsed_body.first["period_month"]).to eq(3)
    end
  end

  describe "POST /api/v1/employees/:employee_id/payroll_entries" do
    let(:params) do
      {
        payroll_entry: {
          period_year: 2026,
          period_month: 7,
          gross_amount: 8000,
          deductions_amount: 500
        }
      }
    end

    it "creates a payroll entry with computed net pay" do
      post "/api/v1/employees/#{employee.id}/payroll_entries",
           params: params.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["net_amount"]).to eq("7500.0")
    end
  end
end
