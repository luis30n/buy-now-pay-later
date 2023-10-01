# frozen_string_literal: true

class ChangeReferenceOnDisbursements < ActiveRecord::Migration[7.0]
  def change
    remove_column :disbursements, :reference
    add_column :disbursements, :reference, :uuid, unique: true, index: true
  end
end
