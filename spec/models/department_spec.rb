require "rails_helper"

RSpec.describe Department, type: :model do
  describe "validations" do
    it "requires unique name (case insensitive)" do
      create(:department, name: "Engineering")
      dup = build(:department, name: "engineering")
      expect(dup).not_to be_valid
      expect(dup.errors[:name]).to include("has already been taken")
    end
  end

  describe "restrict destroy when referenced" do
    it "raises when employees exist" do
      dept = create(:department)
      create(:employee, department: dept)

      expect { dept.destroy! }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
