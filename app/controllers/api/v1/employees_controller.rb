module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: %i[show update destroy]

      def index
        employees = Employee.order(:last_name, :first_name)
        render json: employees.map { |e| employee_payload(e) }
      end

      def show
        render json: employee_payload(@employee)
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee_payload(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: employee_payload(@employee)
        else
          render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @employee.destroy!
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.expect(employee: %i[first_name last_name email department designation base_salary])
      end

      def employee_payload(employee)
        employee.as_json(only: %i[id first_name last_name email department designation base_salary created_at updated_at])
      end
    end
  end
end
