Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      resources :departments, only: %i[index]
      resources :employees, only: %i[index show create update destroy] do
        collection do
          get :export
        end
        resources :payroll_entries, only: %i[index show create update destroy]
      end
    end
  end
end
