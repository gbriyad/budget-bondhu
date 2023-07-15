# frozen_string_literal: true
module Spider
  require 'kimurai'
  require 'uri'

  class ChaldalProductPriceSpiderTest < Kimurai::Base
    @name = "ChaldalProductPriceSpider"
    @engine = :selenium_chrome
    @start_urls = ["https://www.chaldal.com"]
    @config = {
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      disable_images: true,
      restart_if: {
        memory_limit: 2_000_000 # ~1.5GB
      },
      retry_request_errors: [StandardError],
      skip_duplicate_requests: true
    }

    def parse(response, url:, data: {})
      urls = []
      @@mutex = Mutex.new
      response.css(".menu ul.level-0 li a").each do |a|
        urls << absolute_url(a[:href], base: url)
      end

      in_parallel :parse_product_or_category_page, urls , threads: 3
    end

    def parse_product_or_category_page(response, url:, data: {})
      if response.css(".category-links-wrapper").count > 0
        response.css(".category-links-wrapper a").each do |a|
          request_to :parse_product_or_category_page, url: absolute_url(a[:href], base: url)
        end
      else
        parse_product_list_page(response, url: url)
      end
    end

    def parse_product_list_page(response, url:, data: {})
      response = infinite_scroll_through_product_page(response)
      parse_product_section(response)
    end

    def parse_product_section(response)
      full_category, main_category = get_product_category(response)

      response.css('.productPane .product').each do |product_section|
        item = {}

        item[:name] = product_section.css('.name')&.text&.strip
        item[:quantity] = product_section.css('.subText')&.text&.strip
        item[:price] = product_section.css('.price').children[1]&.text&.strip
        item[:discount_price] = product_section.css('.discountedPrice').children[1]&.text&.strip
        item[:main_category] = main_category
        item[:full_category] = full_category
        item[:image_url] = product_section.css('img')&.attr('src')&.text&.strip
        item[:timestamp] = Time.now.utc.to_default_s

        item.transform_values do |value|
          value.presence || ''
        end

        begin
          @@mutex.synchronize do
            @@product_handler.call(item)
          end
        rescue => e
          Rails.logger.error e.message
          p e.message
        end
      end
    end

    # def save_to_csv(item)
    #   file_name = "chaldal-#{@timestamp}.csv"
    #   unless File.exist?(file_name)
    #     CSV.open(file_name, "w") do |csv|
    #       csv << item.keys
    #     end
    #   end
    #   CSV.open(file_name, "a") do |csv|
    #     csv << item.values
    #   end
    # end

    def get_product_category(response)
      full_category = ''
      main_category = ''

      category_nodes = response.css('.categoryHeader .breadcrumb li')
      category_nodes.each_with_index do |category, index|
        full_category += category&.text&.strip
        if index + 1 == category_nodes.count
          main_category = category&.text&.strip
        else
          full_category += ' > '
        end
      end

      return full_category, main_category
    end

    def infinite_scroll_through_product_page(response)
      current_count =  response.css('.productPane .product').count

      loop do
        browser.execute_script("window.scrollBy(0,10000)")
        sleep(2)
        response = browser.current_response

        new_count = response.css('.productPane .product').count
        break if current_count == new_count

        current_count = new_count
      end

      response
    end

  end
end
# Spider::ChaldalProductPriceSpiderTest.crawl!