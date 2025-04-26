# frozen_string_literal: true

class Fee < ApplicationRecord
  REGULAR_CATEGORY = 'regular'
  MIN_MONTHLY_CATEGORY = 'min_monthly'

  enum category: {
    regular: REGULAR_CATEGORY,
    min_monthly: MIN_MONTHLY_CATEGORY
  }

  belongs_to :disbursement
end
