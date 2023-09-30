# frozen_string_literal: true

class Fee < ApplicationRecord
  enum category: {
    regular: 'regular',
    monthly_min: 'monthly_min'
  }

  belongs_to :disbursement
end
