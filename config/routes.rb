Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "dashboard#index"
  get "tickets", to: "tickets#index"
  resources :tickets do
    get :autocomplete_organization_nome, :on => :collection
  end
  get "dashboards", to: "dashboard#index"
end
