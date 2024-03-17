Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "dashboard#index"
  get "tickets", to: "tickets#index"
  resources :tickets do
    get :autocomplete_organization_nome, :on => :collection
  end
  get "dashboards", to: "dashboard#index"
  get "automacoes", to: "automacoes#index"
  post 'automacoes/sync_users', to: 'automacoes#sync_users'
  post 'automacoes/sync_clients', to: 'automacoes#sync_clients'
  post 'automacoes/sync_squads', to: 'automacoes#sync_squads'
  post 'automacoes/sync_tickets', to: 'automacoes#sync_tickets'
end
