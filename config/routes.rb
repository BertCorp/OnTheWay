OnTheWay::Application.routes.draw do

  devise_for :admins, :skip => [:registrations]
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :companies
  as :company do
    get "/login" => "devise/sessions#new", :as => "new_company_session"
    delete "/logout" => "devise/sessions#destroy", :as => "destroy_company_session"
  end

  #resources :companies
  resources :providers
  resources :customers
  resources :appointments

  # test methods
  #get "customer" => "pages#customer"
  #get "provider" => "pages#provider"
  #get "providers/track" => "providers#get_position"
  #post "providers/track" => "providers#set_position"

  get "mobile" => redirect("/provider")
  get "provider" => redirect("/prototypes/provider-v1.0.html")
  get "customer" => redirect("/prototypes/customer-v1.0.html")

  root :to => "pages#index"

end
