# frozen_string_literal: true

class AddReferenceIndexToMerchants < ActiveRecord::Migration[7.0]
  def change
    add_index :merchants, :reference
  end
end
