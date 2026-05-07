require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "validations" do
    it "persists with factory defaults" do
      employee = create(:employee)
      expect(employee).to be_persisted
      expect(employee.department).to be_present
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

  describe ".matching_query" do
    it "returns all employees when q is blank or whitespace" do
      create(:employee, first_name: "Ada")
      create(:employee, first_name: "Grace")
      expect(Employee.matching_query(nil).count).to eq(2)
      expect(Employee.matching_query("   ").count).to eq(2)
    end

    it "matches first_name case-insensitively via ILIKE" do
      hit = create(:employee, first_name: "Marie", last_name: "Curie", email: "marie@example.com")
      create(:employee, first_name: "Ada", last_name: "Lovelace", email: "ada@example.com")
      expect(Employee.matching_query("mar")).to contain_exactly(hit)
    end

    it "matches last_name or email" do
      by_last = create(:employee, first_name: "A", last_name: "Smithson", email: "a1@example.com")
      by_email = create(:employee, first_name: "B", last_name: "Jones", email: "unique@corp.test")
      expect(Employee.matching_query("Smith")).to contain_exactly(by_last)
      expect(Employee.matching_query("unique@")).to contain_exactly(by_email)
    end

    it "escapes LIKE wildcards in the query string" do
      create(:employee, first_name: "100%", last_name: "Match", email: "pct@example.com")
      create(:employee, first_name: "Other", last_name: "Person", email: "other@example.com")
      expect(Employee.matching_query("%").map(&:first_name)).to eq([ "100%" ])
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
