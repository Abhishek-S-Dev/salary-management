require "rails_helper"

RSpec.describe PayrollEntry, type: :model do
  describe "net amount" do
    it "assigns net as gross minus deductions before save" do
      entry = create(:payroll_entry, gross_amount: 12_000, deductions_amount: 2_000, net_amount: 0)
      expect(entry.reload.net_amount).to eq(10_000)
    end
  end

  describe "deductions" do
    it "is invalid when deductions exceed gross" do
      entry = build(:payroll_entry, gross_amount: 1000, deductions_amount: 1001)
      expect(entry).not_to be_valid
      expect(entry.errors[:deductions_amount]).to include("cannot exceed gross amount")
    end
  end

  describe "uniqueness per period" do
    it "does not allow two entries for the same employee and month" do
      employee = create(:employee)
      create(:payroll_entry, employee: employee, period_year: 2026, period_month: 5)
      dup = build(:payroll_entry, employee: employee, period_year: 2026, period_month: 5)
      expect(dup).not_to be_valid
    end
  end
end
