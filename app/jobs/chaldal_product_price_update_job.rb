# frozen_string_literal: true
# require_relative '../services/spider/chaldal_product_price_spider'

class ChaldalProductPriceUpdateJob < ApplicationJob
  def perform
    Rails.logger.info('[ChaldalProductPriceUpdateJob]Starting crawler')

    Spider::ChaldalProductPriceSpider.start_crawl_and_get_products do |p|
      unless p[:name].nil? || p[:quantity].nil? || p[:price].nil?
        product = Product.find_or_create_by!(name: p[:name], quantity: p[:quantity])
        product.category = p[:main_category]
        product.full_category = p[:full_category]
        product.image_url = p[:image_url]

        original_price = p[:price]&.gsub(/\D/, '')&.to_f
        discount_price = p[:discount_price]&.gsub(/\D/, '')&.to_f
        lowest_price = discount_price.nil? ? original_price : discount_price

        unless product.prices.created_recently.any?
          product.prices.create!(original_price: original_price, discount_price: discount_price, lowest_price: lowest_price)
        end
        product.save!
      end
    end

    Rails.logger.info('[ChaldalProductPriceUpdateJob]Crawling Finished')
    # Spider::ChaldalProductPriceSpiderTest.crawl!
  end
end
