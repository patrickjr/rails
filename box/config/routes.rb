Rails.application.routes.draw do
  # get 'home/index'
  devise_for :users

  root 'box_users#index'
  resources :box_users, only: [:index, :create, :destroy]
  get 'box_users/manage/:id', :to => 'box_users#manage'
  get 'box_users/oauth/validate/:id' , :to => 'box_users#oauth_validate'
  get 'box_users/manage/:id/folder/:folder_id', :to => 'box_users#folder'
  
end
