class PayrollEntry < ApplicationRecord
  belongs_to :employee

  before_validation :assign_net_amount

  validates :period_year, presence: true, numericality: { only_integer: true, greater_than: 1999, less_than: 2100 }
  validates :period_month, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 13 }
  validates :period_month, uniqueness: { scope: %i[employee_id period_year], message: "already has payroll for this period" }
  validates :gross_amount, :deductions_amount, :net_amount, presence: true
  validates :gross_amount, :deductions_amount, :net_amount, numericality: { greater_than_or_equal_to: 0 }
  validate :deductions_not_exceed_gross

  private

  def assign_net_amount
    g = gross_amount.to_d
    d = deductions_amount.to_d
    self.net_amount = g - d
  end

  def deductions_not_exceed_gross
    return if gross_amount.blank? || deductions_amount.blank?

    errors.add(:deductions_amount, "cannot exceed gross amount") if deductions_amount.to_d > gross_amount.to_d
  end
end
