# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_231_001_150_954) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'
  enable_extension 'uuid-ossp'

  create_table 'disbursements', force: :cascade do |t|
    t.decimal 'amount', precision: 10, scale: 2
    t.bigint 'merchant_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.uuid 'reference', default: -> { 'uuid_generate_v4()' }
    t.index ['merchant_id'], name: 'index_disbursements_on_merchant_id'
  end

  create_table 'fees', force: :cascade do |t|
    t.decimal 'amount', precision: 10, scale: 2
    t.bigint 'disbursement_id', null: false
    t.string 'category', default: 'regular', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['disbursement_id'], name: 'index_fees_on_disbursement_id'
  end

  create_table 'merchants', force: :cascade do |t|
    t.string 'reference'
    t.string 'email'
    t.date 'live_on'
    t.string 'disbursement_frequency'
    t.decimal 'minimum_monthly_fee', precision: 10, scale: 2
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['reference'], name: 'index_merchants_on_reference'
  end

  create_table 'orders', force: :cascade do |t|
    t.bigint 'merchant_id', null: false
    t.bigint 'disbursement_id'
    t.decimal 'amount', precision: 10, scale: 2
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['disbursement_id'], name: 'index_orders_on_disbursement_id'
    t.index ['merchant_id'], name: 'index_orders_on_merchant_id'
  end

  add_foreign_key 'disbursements', 'merchants'
  add_foreign_key 'fees', 'disbursements'
  add_foreign_key 'orders', 'disbursements'
  add_foreign_key 'orders', 'merchants'
end
