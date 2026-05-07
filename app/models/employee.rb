class Employee < ApplicationRecord
  has_many :payroll_entries, dependent: :destroy

  scope :matching_query, lambda { |raw|
    q = raw.to_s.strip
    next all if q.blank?

    pattern = "%#{Employee.sanitize_sql_like(q)}%"
    where("employees.first_name ILIKE ? OR employees.last_name ILIKE ? OR employees.email ILIKE ?", pattern, pattern, pattern)
  }

  validates :first_name, :last_name, :email, :base_salary, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :base_salary, numericality: { greater_than: 0 }
end
