OnTheWay::Application.routes.draw do

  devise_for :admins, :skip => [:registrations]
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # Administrative Routes
  #resque_constraint = lambda do |request|
  #  request.env['warden'].user && request.env['warden'].user(:admin)
  #end
  #constraints resque_constraint do
  #  mount Resque::Server, :at => "/resque"
  #end
  resources :providers
  resources :customers

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
        delete "appointments/:id" => "appointments#destroy"

        get "appointments/:id/tracking" => "appointments#tracking_show"
        put "appointments/:id/tracking" => "appointments#tracking_update"
        delete "appointments/:id/tracking" => "appointments#tracking_destroy"
      end
    end
  end

  devise_for :companies
  as :company do
    get "/login" => "devise/sessions#new", :as => "new_company_session"
    delete "/logout" => "devise/sessions#destroy", :as => "destroy_company_session"
    get "/logout" => "devise/sessions#destroy"
  end

  get "p" => redirect("/prototypes/provider-v1.0.html")
  get "p/:id" => redirect("/prototypes/provider-v1.0.html")
  get "a/:id" => "customers#appointment"

  # test methods
  get "test/customer" => "pages#customer"
  get "test/provider" => "pages#provider"
  get "providers/track" => "providers#get_position"
  post "providers/track" => "providers#set_position"

  get "appointments/import" => "appointments#import", as: "import_appointments"
  post "appointments/upload" => "appointments#upload"
  resources :appointments


  get "mobile" => redirect("/provider")
  get "provider" => redirect("/mockups/provider-v1.0.html")
  get "customer" => redirect("/mockups/customer-v1.0.html")
  get "feedback" => redirect("/mockups/customer-feedback-v1.0.html")

  match "sms_reply", :to => "pages#sms_reply", :defaults => { :format => 'xml' }
  match "pro_marketing", :to => "pages#pro_marketing"
  match "pro_marketing_confirmation", :to => "pages#pro_marketing_confirmation"
  match "landing_confirmation", :to => "pages#landing_confirmation"

  root :to => "pages#index"

end
