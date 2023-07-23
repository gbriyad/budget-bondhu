class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :set_default_time_period, only: %i[ index ]

  # GET /products or /products.json
  def index
    @products = Product.get_profitable_products(@start_time)
    @categories = @products.pluck(:category).uniq

    @products = @products.where(category: params[:categories]) if params[:categories].present?
    @products = @products.paginate(page: params[:page], per_page: 10)

    change_rates_map = Product.get_product_ids_to_price_change_rates(@products.pluck(:id), @start_time)
    min_prices_map = Product.get_product_ids_to_min_prices(@products.pluck(:id), @start_time)
    max_prices_map = Product.get_product_ids_to_max_prices(@products.pluck(:id), @start_time)

    # @products = @products.includes(:prices) # need eager loading before assigning attribute values, otherwise attribute values will be nil

    @products.each do |product|
      product.change_rate = change_rates_map[product.id]
      product.min_price = min_prices_map[product.id]
      product.max_price = max_prices_map[product.id]
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
      params[:time_period] = 1.week
      @start_time = 1.week.ago
    end
  end
end
