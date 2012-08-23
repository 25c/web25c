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

ActiveRecord::Schema.define(:version => 20120822203903) do

  create_table "buttons", :force => true do |t|
    t.string   "uuid",                 :null => false
    t.integer  "user_id",              :null => false
    t.string   "size"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "code_type"
    t.string   "youtube_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "info_url"
  end

  add_index "buttons", ["user_id"], :name => "index_buttons_on_user_id"

  create_table "payments", :force => true do |t|
    t.string   "uuid",                        :null => false
    t.integer  "user_id",                     :null => false
    t.integer  "amount"
    t.integer  "state",        :default => 0, :null => false
    t.string   "payment_type",                :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "payments", ["user_id"], :name => "index_payments_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "uuid",                                     :null => false
    t.string   "email"
    t.string   "password_digest"
    t.string   "facebook_uid"
    t.string   "facebook_code"
    t.string   "facebook_access_token"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "is_admin",              :default => false, :null => false
    t.integer  "balance",               :default => 0,     :null => false
    t.string   "card_token"
    t.boolean  "auto_refill",           :default => true
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "about"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.boolean  "is_new",                :default => true
    t.string   "twitter_uid"
    t.string   "twitter_username"
    t.string   "twitter_token"
    t.string   "twitter_token_secret"
    t.string   "google_uid"
    t.string   "google_token"
    t.string   "google_refresh_token"
    t.string   "picture_url"
    t.boolean  "has_agreed",            :default => false
    t.boolean  "show_donations",        :default => true
    t.string   "paypal_email"
    t.string   "dwolla_email"
  end

  add_index "users", ["google_uid"], :name => "index_users_on_google_uid", :unique => true
  add_index "users", ["twitter_uid"], :name => "index_users_on_twitter_uid", :unique => true

end
