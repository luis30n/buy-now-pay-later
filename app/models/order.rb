# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true

  scope :undisbursed, -> { where(disbursement_id: nil) }
end
