class Price < ApplicationRecord
  belongs_to :product

  scope :created_recently, -> { where("created_at > ?", 1.hours.ago) }
end
