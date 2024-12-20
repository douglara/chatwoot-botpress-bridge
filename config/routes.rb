Rails.application.routes.draw do
  post 'chatwoot/webhook'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
