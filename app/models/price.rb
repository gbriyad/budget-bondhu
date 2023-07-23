class Price < ApplicationRecord
  belongs_to :product
  enum time_period: {last_1_week: 1.week, last_2_weeks: 2.weeks,
                     last_1_month: 1.month, last_3_months: 3.months, last_6_months: 6.months,
                     last_1_year: 1.year, last_2_years: 2.years}

  scope :created_recently, -> { where("created_at > ?", 1.hours.ago) }

end
