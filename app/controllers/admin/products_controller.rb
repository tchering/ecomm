class Admin::ProductsController < AdminController
  before_action :set_product, only: %i[ show edit update destroy ]
  layout "admin"

  # GET /admin/products or /admin/products.json
  def index
    @products = Product.includes(:category, :stocks, images_attachments: :blob).all

    # Filter by category
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    # Filter by status
    @products = @products.where(active: true) if params[:status] == "active"
    @products = @products.where(active: false) if params[:status] == "inactive"

    # Filter by stock status
    if params[:stock_status].present?
      case params[:stock_status]
      when "in_stock"
        @products = @products.joins(:stocks).group("products.id").having("SUM(stocks.quantity) > 0")
        # Exclude products with any stock below reorder level
        @products = @products.where.not(id: Product.joins(:stocks).where("stocks.quantity < stocks.reorder_level").select(:id))
      when "out_of_stock"
        @products = @products.left_joins(:stocks).group("products.id").having("COALESCE(SUM(stocks.quantity), 0) = 0")
      when "low_stock"
        # Products with stock > 0 but at least one stock record below reorder level
        @products = @products.joins(:stocks).where("stocks.quantity < stocks.reorder_level AND stocks.quantity > 0").group("products.id")
      end
    end

    # Search by title, description or SKU
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @products = @products.where("title ILIKE ? OR description ILIKE ?", search_term, search_term)
    end

    # Sort products
    case params[:sort]
    when "title_asc"
      @products = @products.order(title: :asc)
    when "title_desc"
      @products = @products.order(title: :desc)
    when "price_asc"
      @products = @products.order(price: :asc)
    when "price_desc"
      @products = @products.order(price: :desc)
    when "created_asc"
      @products = @products.order(created_at: :asc)
    when "created_desc"
      @products = @products.order(created_at: :desc)
    else
      @products = @products.order(created_at: :desc)
    end

    # Pagination
    @products = @products.page(params[:page]).per(10)

    # Get all categories for the filter dropdown
    @categories = Category.all.order(:title)
  end

  # GET /admin/products/1 or /admin/products/1.json
  def show
    @stocks = @product.stocks
  end

  # GET /admin/products/new
  def new
    @product = Product.new
  end

  # GET /admin/products/1/edit
  def edit
  end

  # POST /admin/products or /admin/products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to admin_product_path(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/products/1 or /admin/products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to admin_product_path(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/products/1 or /admin/products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to admin_products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # DELETE /admin/products/1/images/1
  def destroy_image
    @product = Product.find(params[:product_id])
    image = @product.images.find(params[:image_id])
    image.purge

    respond_to do |format|
      format.html { redirect_to edit_admin_product_path(@product), notice: "Image was successfully removed." }
      format.json { head :no_content }
    end
  end

  # POST /admin/products/bulk_action
  def bulk_action
    product_ids = params[:product_ids]
    action = params[:bulk_action]

    if product_ids.blank?
      redirect_to admin_products_path, alert: "No products selected."
      return
    end

    case action
    when "activate"
      Product.where(id: product_ids).update_all(active: true)
      message = "Selected products have been activated."
    when "deactivate"
      Product.where(id: product_ids).update_all(active: false)
      message = "Selected products have been deactivated."
    when "delete"
      Product.where(id: product_ids).destroy_all
      message = "Selected products have been deleted."
    when "update_category"
      category_id = params[:category_id]
      if category_id.present?
        Product.where(id: product_ids).update_all(category_id: category_id)
        message = "Selected products have been moved to the new category."
      else
        redirect_to admin_products_path, alert: "Please select a category."
        return
      end
    else
      redirect_to admin_products_path, alert: "Invalid action."
      return
    end

    redirect_to admin_products_path, notice: message
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.includes(images_attachments: :blob).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:title, :description, :price, :active, :category_id, :tax_rate, :sku, images: [])
  end
end
