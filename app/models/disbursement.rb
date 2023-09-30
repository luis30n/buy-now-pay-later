# frozen_string_literal: true

class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders, dependent: :restrict_with_exception
  has_many :fees, dependent: :restrict_with_exception
end
