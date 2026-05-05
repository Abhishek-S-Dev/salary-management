require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "validations" do
    it "is valid with factory defaults" do
      expect(build(:employee)).to be_valid
    end

    it "requires email uniqueness (case insensitive)" do
      create(:employee, email: "person@example.com")
      dup = build(:employee, email: "Person@Example.com")
      expect(dup).not_to be_valid
      expect(dup.errors[:email]).to include("has already been taken")
    end

    it "requires a positive base salary" do
      employee = build(:employee, base_salary: 0)
      expect(employee).not_to be_valid
    end
  end

  describe "associations" do
    it "destroys payroll entries when destroyed" do
      employee = create(:employee)
      create(:payroll_entry, employee: employee)
      expect { employee.destroy! }.to change(PayrollEntry, :count).by(-1)
    end
  end
end
