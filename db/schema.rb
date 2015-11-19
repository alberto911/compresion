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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151118072055) do

  create_table "estadisticas", force: :cascade do |t|
    t.string   "cuantificacion", limit: 255, null: false
    t.integer  "colores",        limit: 4,   null: false
    t.integer  "iteraciones",    limit: 4
    t.integer  "bytes_inicio",   limit: 4,   null: false
    t.integer  "bytes_fin",      limit: 4,   null: false
    t.integer  "pixeles",        limit: 4,   null: false
    t.float    "tiempo",         limit: 24,  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "tramado",        limit: 255
  end

end
