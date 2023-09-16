class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy]
  before_action :set_default_time_period, only: %i[ index ]

  # GET /products or /products.json
  def index
    @profitable_products, @profitable_categories = Rails.cache.fetch("profitable_products_#{params[:categories]}_#{params[:profitable_products_page]}_#{params[:time_period]}", expires_in: 20.minutes) do
      profitable_products = Product.get_profitable_products(@start_time)
      profitable_categories = profitable_products.pluck(:category).uniq

      profitable_products = profitable_products.where(category: params[:categories]) if params[:categories].present?
      profitable_products = profitable_products.paginate(page: params[:profitable_products_page], per_page: 18)

      change_rates_map = Product.get_product_ids_to_price_change_rates(profitable_products.pluck(:id), @start_time)
      min_prices_map = Product.get_product_ids_to_min_prices(profitable_products.pluck(:id), @start_time)
      max_prices_map = Product.get_product_ids_to_max_prices(profitable_products.pluck(:id), @start_time)

      # @products = @products.includes(:prices) # need eager loading before assigning attribute values, otherwise attribute values will be nil

      profitable_products.each do |product|
        product.change_rate = change_rates_map[product.id]
        product.min_price = min_prices_map[product.id]
        product.max_price = max_prices_map[product.id]
      end

      [profitable_products, profitable_categories]
    end
    
    @non_profitable_products, @non_profitable_categories = Rails.cache.fetch("non_profitable_products_#{params[:categories]}_#{params[:non_profitable_products_page]}_#{params[:time_period]}", expires_in: 20.minutes) do
      non_profitable_products = Product.get_non_profitable_products(@start_time)
      non_profitable_categories = non_profitable_products.pluck(:category).uniq

      non_profitable_products = non_profitable_products.where(category: params[:categories]) if params[:categories].present?
      non_profitable_products = non_profitable_products.paginate(page: params[:non_profitable_products_page], per_page: 18)

      change_rates_map = Product.get_product_ids_to_price_change_rates(non_profitable_products.pluck(:id), @start_time)
      min_prices_map = Product.get_product_ids_to_min_prices(non_profitable_products.pluck(:id), @start_time)
      max_prices_map = Product.get_product_ids_to_max_prices(non_profitable_products.pluck(:id), @start_time)

      # @products = @products.includes(:prices) # need eager loading before assigning attribute values, otherwise attribute values will be nil

      non_profitable_products.each do |product|
        product.change_rate = change_rates_map[product.id]
        product.min_price = min_prices_map[product.id]
        product.max_price = max_prices_map[product.id]
      end
      [non_profitable_products, non_profitable_categories]
    end
    
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def prices_chart
    data = Rails.cache.fetch("prices_chart_#{params[:id]}_#{params[:start_time]}") do
      product = Product.find(params[:id])
      [{ name: 'original-price', data: product.prices.where('created_at >= ?', params[:start_time]).pluck(:created_at, :original_price) },
       { name: 'discounted-price', data: product.prices.where('created_at >= ?', params[:start_time]).pluck(:created_at, :discount_price) }
      ]
    end
    render json: data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :quantity, :category, :full_category, :image_url)
    end

  def set_default_time_period
    time_period_int = params[:time_period]&.to_i

    if Price.time_periods.values.include?(time_period_int)
      @start_time = time_period_int.seconds.ago
    else
      params[:time_period] = 2.weeks
      @start_time = 2.weeks.ago
    end
  end
end
