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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_30_212801) do

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "msg_type"
    t.string "sender"
    t.string "destinatary"
    t.text "text"
    t.string "blob_url"
    t.datetime "time"
    t.integer "duration"
    t.string "status"
    t.string "auto_text"
    t.text "background_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "digest"
    t.string "direction"
    t.bigint "account_id"
    t.string "conv_type"
    t.string "conv_title"
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["digest"], name: "index_messages_on_digest"
  end

  add_foreign_key "messages", "accounts"
end
