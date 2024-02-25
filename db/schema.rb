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

ActiveRecord::Schema.define(version: 2024_02_25_190538) do

  create_table "groups", force: :cascade do |t|
    t.string "nome"
    t.string "descricao"
    t.datetime "criado_em"
    t.datetime "atualizado_em"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "nome"
    t.string "dominios"
    t.string "detalhes"
    t.string "tenant"
    t.string "tags"
    t.datetime "criado_em"
    t.datetime "atualizado_em"
  end

  create_table "systems", force: :cascade do |t|
    t.string "url"
    t.string "username"
    t.string "token"
    t.string "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "requester_id"
    t.string "prioridade"
    t.string "status"
    t.integer "group_id"
    t.integer "atribuido"
    t.string "observacoes"
    t.string "categoria"
    t.string "regiao"
    t.string "tipo_cliente"
    t.string "tags"
    t.datetime "criado_em"
    t.datetime "atualizado_em"
  end

  create_table "users", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.integer "organization_id"
    t.string "role"
    t.integer "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
