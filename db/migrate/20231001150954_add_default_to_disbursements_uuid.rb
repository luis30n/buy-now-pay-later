# frozen_string_literal: true

class AddDefaultToDisbursementsUuid < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

    change_column :disbursements, :reference, :uuid, default: 'uuid_generate_v4()'
  end
end
