class Product < ApplicationRecord
  attr_accessor :change_rate, :min_price, :max_price
  has_many :prices

  CATEGORY_ALL_PRODUCTS = 'All Products'.freeze

  ########################### class methods start ##########################

  def self.get_profitable_products(start_time)
    product_ids_to_price_change_rates = get_product_ids_to_price_change_rates(all.pluck(:id), start_time)
    product_ids_to_price_change_rates.select! {|x,v| v < 0.0}

    sorted_product_ids = product_ids_to_price_change_rates.sort_by {|_, change_rate| change_rate }.map(&:first)
    where(id: sorted_product_ids).order_by_ids(sorted_product_ids)
  end

  def self.get_non_profitable_products(start_time)
    product_ids_to_price_change_rates = get_product_ids_to_price_change_rates(all.pluck(:id), start_time)
    product_ids_to_price_change_rates.select! {|x,v| v > 0.0}

    sorted_product_ids = product_ids_to_price_change_rates.sort_by {|_, change_rate| change_rate }.reverse.map(&:first)
    where(id: sorted_product_ids).order_by_ids(sorted_product_ids)
  end

  def self.get_product_ids_to_price_change_rates(product_ids, start_time)

    product_ids_to_price_change_rates = {}
    product_ids_to_avg_prices = Price.where("prices.created_at >= ?", start_time).group(:product_id).average(:lowest_price)

    last_price_ids = Price.where(product_id: product_ids).where("prices.created_at >= ?", start_time).group(:product_id).pluck('max(id)')
    product_ids_to_last_prices = Price.where(id: last_price_ids).where("prices.created_at >= ?", 1.day.ago).pluck(:product_id, :lowest_price)

    product_ids_to_last_prices.each do |product_id, last_price|
      avg_price = product_ids_to_avg_prices[product_id]
      next if avg_price.nil? || avg_price == 0.0
      product_ids_to_price_change_rates[product_id] = (last_price - avg_price) * 100.0 / avg_price
    end

    product_ids_to_price_change_rates
  end

  def self.get_product_ids_to_min_prices(product_ids, start_time)
    Price.where(product_id: product_ids).where("prices.created_at >= ?", start_time).group(:product_id).minimum(:lowest_price)
  end

  def self.get_product_ids_to_max_prices(product_ids, start_time)
    Price.where(product_id: product_ids).where("prices.created_at >= ?", start_time).group(:product_id).maximum(:lowest_price)
  end

  private

  # def self.get_price_change_rates(products, date_range)
  #   date_window =
  #     case date_range
  #     when last_1_week
  #       1.week
  #     when last_1_month
  #       1.month
  #     when last_1_year
  #       1.year
  #     else
  #       1.week
  #     end
  #
  #   product_ids_to_price_change_rates = {}
  #
  #   products.joins(:prices).includes(:prices).where("prices.created_at >= ?", (date_window+2.days).ago).each do |product|
  #     last_price_creation_time = product.prices.last.created_at.localtime
  #     next if last_price_creation_time < (Time.now - 1.day)
  #
  #     today_time_range = last_price_creation_time.beginning_of_day..last_price_creation_time.end_of_day
  #
  #     past_prices_end_time = (last_price_creation_time - 1.day).end_of_day
  #     past_time_range = (past_prices_end_time - date_window).beginning_of_day..past_prices_end_time
  #
  #     average_price_today = 0.0
  #     average_price_in_past = 0.0
  #     today_prices_count = 0
  #     past_prices_count = 0
  #
  #     product.prices.each do |price|
  #       if today_time_range.cover?(price.created_at.localtime)
  #         today_prices_count += 1
  #         average_price_today += price.lowest_price
  #       elsif past_time_range.cover?(price.created_at.localtime)
  #         past_prices_count += 1
  #         average_price_in_past += price.lowest_price
  #       end
  #     end
  #     average_price_today = average_price_today/today_prices_count.to_f
  #     average_price_in_past = average_price_in_past/past_prices_count.to_f
  #
  #     next if today_prices_count == 0 || past_prices_count == 0
  #
  #     # populate data
  #     price_change_rate = (average_price_today - average_price_in_past) * 100.0 / average_price_in_past
  #
  #     next if price_change_rate == 0.0
  #     product_ids_to_price_change_rates[product.id] = price_change_rate
  #   end
  #
  #   product_ids_to_price_change_rates
  # end
end
