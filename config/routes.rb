OnTheWay::Application.routes.draw do

  devise_for :admins, :skip => [:registrations]
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :companies
  as :company do
    get "/login" => "devise/sessions#new", :as => "new_company_session"
    delete "/logout" => "devise/sessions#destroy", :as => "destroy_company_session"
  end

  devise_for :providers, :skip => [:registrations, :passwords]
  as :provider do
    post "providers/login" => "devise/sessions#create", :as => "provider_session"
    delete "providers/logout" => "devise/sessions#destroy", :as => "destroy_provider_session"
    #get 'providers/edit' => 'devise/registrations#edit', :as => 'edit_provider_registration'
    put 'providers' => 'devise/registrations#update', :as => 'provider_registration'
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
  get "provider" => redirect("/mockups/provider-v1.0.html")
  get "customer" => redirect("/mockups/customer-v1.0.html")
  get "feedback" => redirect("/mockups/customer-feedback-v1.0.html")

  root :to => "pages#index"

end
