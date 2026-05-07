require "csv"

module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: %i[show update destroy]

      def index
        scope = Employee.includes(:department).order(:last_name, :first_name)
        scope = scope.matching_query(params[:q]) if params[:q].present?
        page = [ params.fetch(:page, 1).to_i, 1 ].max
        per_raw = params.fetch(:per_page, 20).to_i
        per_page = [ [ per_raw, 1 ].max, 100 ].min
        total_count = scope.count
        employees = scope.offset((page - 1) * per_page).limit(per_page)
        render json: {
          data: employees.map { |e| employee_payload(e) },
          meta: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: per_page.positive? ? (total_count.to_f / per_page).ceil : 0
          }
        }
      end

      def export
        scope = Employee.includes(:department).order(:last_name, :first_name)
        csv_string = CSV.generate(headers: true) do |csv|
          csv << %w[id email first_name last_name designation department_name department_note base_salary]
          scope.find_each do |emp|
            csv << [
              emp.id,
              emp.email,
              emp.first_name,
              emp.last_name,
              emp.designation,
              emp.department&.name,
              emp.department_note,
              emp.base_salary
            ]
          end
        end
        send_data csv_string,
          filename: "employees-#{Date.current.iso8601}.csv",
          type: "text/csv; charset=utf-8",
          disposition: "attachment"
      end

      def show
        render json: employee_payload(@employee)
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee_payload(employee.reload), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: employee_payload(@employee.reload)
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
        @employee = Employee.includes(:department).find(params[:id])
      end

      def employee_params
        params.expect(employee: %i[first_name last_name email designation department_id base_salary department_note])
      end

      def employee_payload(employee)
        h = employee.as_json(
          only: %i[id first_name last_name email designation department_note department_id base_salary created_at updated_at]
        )
        dept = employee.department
        h["department"] = { id: dept.id, name: dept.name } if dept
        h
      end
    end
  end
end
