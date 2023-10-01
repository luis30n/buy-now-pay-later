# frozen_string_literal: true

class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders, dependent: :restrict_with_exception
  has_many :fees, dependent: :restrict_with_exception

  def first_of_month?
    merchant.disbursements.where(
      'created_at >= ? AND created_at < ?',
      created_at.beginning_of_month,
      created_at
    ).empty?
  end
end
