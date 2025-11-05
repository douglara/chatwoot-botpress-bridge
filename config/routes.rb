Rails.application.routes.draw do
  get 'pages/home'
  post 'chatwoot/webhook'
  post 'botpress/webhook'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
