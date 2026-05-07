module Api
  module V1
    class HealthController < BaseController
      def show
        ActiveRecord::Base.connection.execute("SELECT 1")
        render json: { ok: true, database: "connected" }
      rescue StandardError => e
        render json: { ok: false, database: "error", error: e.message }, status: :service_unavailable
      end
    end
  end
end
