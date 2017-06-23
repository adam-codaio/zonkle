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

ActiveRecord::Schema.define(:version => 20130730041145) do

  create_table "algorithms", :force => true do |t|
    t.integer  "atype"
    t.string   "name"
    t.string   "desc"
    t.text     "algo"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "labels", :force => true do |t|
    t.text     "desc"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "seed"
    t.integer  "world_id"
  end

  create_table "parameters", :force => true do |t|
    t.string   "param"
    t.string   "desc"
    t.text     "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "world_id"
  end

  create_table "test_results", :force => true do |t|
    t.integer  "test_id"
    t.integer  "labela_id"
    t.integer  "labelb_id"
    t.integer  "choice_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tests", :force => true do |t|
    t.integer  "explicit_label_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "end_label_id"
    t.text     "input_labels"
    t.integer  "subject_id"
    t.string   "ip"
    t.string   "host"
    t.string   "browser"
    t.integer  "world_id"
    t.string   "subject_data"
  end

  create_table "worlds", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "start"
  end

end
