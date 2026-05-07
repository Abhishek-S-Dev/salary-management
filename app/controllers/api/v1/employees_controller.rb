module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: %i[show update destroy]

      def index
        scope = Employee.order(:last_name, :first_name)
        scope = scope.matching_query(params[:q]) if params[:q].present?
        page = [params.fetch(:page, 1).to_i, 1].max
        per_raw = params.fetch(:per_page, 20).to_i
        per_page = [[per_raw, 1].max, 100].min
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
