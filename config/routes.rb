OnTheWay::Application.routes.draw do

  devise_for :admins, :skip => [:registrations]
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :providers
  as :provider do
    namespace "api" do
      namespace "v0" do
        get "check" => "sessions#check"
        post "login" => "sessions#create", as: "new_provider_session"
        get "logout" => "sessions#destroy", as: "logout"
        delete "logout" => "sessions#destroy", as: "destroy_provider_session"

        get "appointments" => "appointments#index", as: "appointments"
        post "appointments" => "appointments#create"
        get "appointments/1" => "appointments#show"
        put "appointments/1" => "appointments#update"
        delete "appointments/1" => "appointments#destroy"

      end
    end
  end


  devise_for :companies
  as :company do
    get "/login" => "devise/sessions#new", :as => "new_company_session"
    delete "/logout" => "devise/sessions#destroy", :as => "destroy_company_session"
  end

=begin
  devise_for :providers, :skip => [:registrations, :passwords]
  as :provider do
    post "providers/login" => "devise/sessions#create", :as => "provider_session"
    delete "providers/logout" => "devise/sessions#destroy", :as => "destroy_provider_session"
    #get 'providers/edit' => 'devise/registrations#edit', :as => 'edit_provider_registration'
    put 'providers' => 'devise/registrations#update', :as => 'provider_registration'
  end
=end

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
