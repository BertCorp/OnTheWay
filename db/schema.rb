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

ActiveRecord::Schema.define(:version => 20130604213122) do

  create_table "appointments", :force => true do |t|
    t.integer  "company_id"
    t.integer  "provider_id"
    t.integer  "customer_id"
    t.string   "shortcode"
    t.datetime "when"
    t.text     "where"
    t.text     "provider_location"
    t.string   "status"
    t.integer  "rating"
    t.text     "feedback"
    t.datetime "confirmed_at"
    t.datetime "arrived_at"
    t.datetime "finished_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end