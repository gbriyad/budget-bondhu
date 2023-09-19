module ProductsHelper
  def show_product_name(product)
    "#{product.name.split('(±').first.split('±').first.strip}(#{product.quantity})"
  end

  def show_product_change_rate(product)
    "#{'+' if product.change_rate > 0.0}#{number_with_precision(product.change_rate, precision: 2)}%"
  end

  def show_growth_icon(product)
    image_file_name = product.change_rate > 0.0 ? 'positive-growth.svg' : 'negative-growth.svg'
    image_tag image_file_name, class: 'img-fluid'
  end
end
