module Api
  module V1
    class PayrollEntriesController < BaseController
      before_action :set_employee
      before_action :set_payroll_entry, only: %i[show update destroy]

      def index
        entries = @employee.payroll_entries.order(period_year: :desc, period_month: :desc)
        render json: entries.map { |e| payroll_payload(e) }
      end

      def show
        render json: payroll_payload(@payroll_entry)
      end

      def create
        entry = @employee.payroll_entries.build(payroll_params)
        if entry.save
          render json: payroll_payload(entry), status: :created
        else
          render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @payroll_entry.update(payroll_params)
          render json: payroll_payload(@payroll_entry)
        else
          render json: { errors: @payroll_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @payroll_entry.destroy!
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:employee_id])
      end

      def set_payroll_entry
        @payroll_entry = @employee.payroll_entries.find(params[:id])
      end

      def payroll_params
        params.expect(payroll_entry: %i[period_year period_month gross_amount deductions_amount])
      end

      def payroll_payload(entry)
        entry.as_json(only: %i[id employee_id period_year period_month gross_amount deductions_amount net_amount created_at updated_at])
      end
    end
  end
end
