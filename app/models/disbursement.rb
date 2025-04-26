# frozen_string_literal: true

class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders, dependent: :restrict_with_exception
  has_many :fees, dependent: :restrict_with_exception

  def first_of_month?(date:)
    return true if date == date.beginning_of_month
    
    date < date.beginning_of_month + 7.days && merchant.disbursement_frequency == Merchant::WEEKLY_FREQUENCY
  end
end
