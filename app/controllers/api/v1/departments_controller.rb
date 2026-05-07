module Api
  module V1
    class DepartmentsController < BaseController
      def index
        departments = Department.order(:name)
        render json: departments.map { |d| { id: d.id, name: d.name } }
      end
    end
  end
end
