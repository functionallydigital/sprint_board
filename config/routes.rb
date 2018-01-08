Rails.application.routes.draw do
  root 'projects#index'

  resources :projects
  resources :status
  resources :sprints
  resources :epics
  resources :stories
  resources :tasks

  get '/projects/:id/backlog', to: 'projects#backlog', as: 'project_backlog'
  get '/projects/:id/users', to: 'projects#users', as: 'project_users'
  post '/projects/:id/add_user', to: 'projects#add_user', as: 'add_user'
  post '/projects/:id/add_step', to: 'projects#add_step', as: 'add_step'
  get '/projects/:id/roadmap', to: 'projects#roadmap', as: 'roadmap'

  put '/epics/:id/update_sprint_number', to: 'epics#update_sprint_number', as: 'update_epic_sprint_number'

  post '/stories/:id/assign_user', to: 'stories#assign_user', as: 'add_story_user'

  get '/register', to: 'users#new', as: 'register'
  get '/users/selector_list', to: 'users#selector_list', as: 'user_selector_list'
  resources :users

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#delete'

  get '/priorities', to: 'priorities#index', as: 'priorities'
end
