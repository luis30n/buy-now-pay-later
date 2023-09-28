# frozen_string_literal: true

class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements do |t|
      t.string :reference
      t.decimal :amount, precision: 10, scale: 2
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
