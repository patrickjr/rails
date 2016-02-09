Rails.application.routes.draw do
  # get 'home/index'

  devise_for :users


  root 'box_users#index'
  resources :box_users, only: [:index, :create, :destroy]
  get 'box_users/manage/:key/:value', :to => 'box_users#manage'

end
