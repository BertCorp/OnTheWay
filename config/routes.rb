OnTheWay::Application.routes.draw do

  devise_for :admins, :skip => [:registrations]
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :providers
  as :provider do
    namespace "api" do
      namespace "v0" do
        get "check" => "sessions#check"
        post "login" => "sessions#create", as: "new_provider_session"
        get "logout" => "sessions#destroy"
        delete "logout" => "sessions#destroy", as: "destroy_provider_session"

        get "appointments" => "appointments#index", as: "appointments"
        post "appointments" => "appointments#create"
        get "appointments/:id" => "appointments#show"
        put "appointments/:id" => "appointments#update"
        put "appointments/:id/feedback" => "appointments#feedback"
        #delete "appointments/:id" => "appointments#destroy"

        get "appointments/:id/tracking" => "appointments#tracking_show"
        put "appointments/:id/tracking" => "appointments#tracking_update"
      end
    end
  end

  devise_for :companies
  as :company do
    get "login" => "devise/sessions#new", :as => "new_company_session"
    delete "logout" => "devise/sessions#destroy", :as => "destroy_company_session"
  end

  resources :providers
  resources :customers
  resources :appointments

  get "p/:id" => redirect("/prototypes/provider-v1.0.html?id=:id")
  get "a/:id" => "customers#appointment"

  # test methods
  #get "customer" => "pages#customer"
  #get "provider" => "pages#provider"
  #get "providers/track" => "providers#get_position"
  #post "providers/track" => "providers#set_position"

  get "mobile" => redirect("/provider")
  get "provider" => redirect("/mockups/provider-v1.0.html")
  get "customer" => redirect("/mockups/customer-v1.0.html")
  get "feedback" => redirect("/mockups/customer-feedback-v1.0.html")
  
  match "pro_marketing", :to => "pages#pro_marketing"

  root :to => "pages#index"

end
