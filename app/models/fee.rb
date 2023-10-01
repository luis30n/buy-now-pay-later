# frozen_string_literal: true

class Fee < ApplicationRecord
  enum category: {
    regular: 'regular',
    min_monthly: 'min_monthly'
  }

  belongs_to :disbursement
end
