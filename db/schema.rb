# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130725144222) do

  create_table "admins", :force => true do |t|
    t.string   "name",                   :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "appointments", :force => true do |t|
    t.integer  "company_id"
    t.integer  "provider_id"
    t.integer  "customer_id"
    t.string   "shortcode"
    t.datetime "starts_at"
    t.text     "location"
    t.string   "status"
    t.integer  "rating"
    t.text     "feedback"
    t.datetime "confirmed_at"
    t.datetime "en_route_at"
    t.datetime "arrived_at"
    t.datetime "finished_at"
<<<<<<< HEAD
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "en_route_at"
    t.text     "notes"
=======
    t.text     "notes"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
>>>>>>> 003-add_customers
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "email",                  :default => "",                :null => false
    t.string   "encrypted_password",     :default => "",                :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "timezone",               :default => "America/Chicago"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "companies", ["email"], :name => "index_companies_on_email", :unique => true
  add_index "companies", ["reset_password_token"], :name => "index_companies_on_reset_password_token", :unique => true

  create_table "companies_customers", :force => true do |t|
    t.integer "company_id"
    t.integer "customer_id"
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "providers", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "phone"
<<<<<<< HEAD
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
=======
    t.string   "device_uid"
>>>>>>> 003-add_customers
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "timezone"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "providers", ["email"], :name => "index_providers_on_email", :unique => true
  add_index "providers", ["invitation_token"], :name => "index_providers_on_invitation_token"
  add_index "providers", ["invited_by_id"], :name => "index_providers_on_invited_by_id"
  add_index "providers", ["reset_password_token"], :name => "index_providers_on_reset_password_token", :unique => true

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

end
