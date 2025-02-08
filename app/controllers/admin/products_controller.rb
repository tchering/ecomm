class Admin::ProductsController < AdminsController
  before_action :set_admin_product, only: %i[ show edit update destroy ]
  layout "admin"

  # GET /admin/products or /admin/products.json
  def index
    # Here category_id is received from url in _category.html.erb
    #  <%= link_to admin_products_path(category_id: category.id) do%>
    @admin_products = if params[:category_id]
        Product.where(category_id: params[:category_id])
      else
        @admin_products = Product.all
      end
  end

  # GET /admin/products/1 or /admin/products/1.json
  def show
  end

  # GET /admin/products/new
  def new
    @admin_product = Product.new
  end

  # GET /admin/products/1/edit
  def edit
  end

  # POST /admin/products or /admin/products.json
  def create
    @admin_product = Product.new(admin_product_params)

    respond_to do |format|
      if @admin_product.save
        format.html { redirect_to admin_products_path, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @admin_product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/products/1 or /admin/products/1.json
  def update
    respond_to do |format|
      # First update the basic attributes
      if @admin_product.update(admin_product_params.except(:images))
        #Then attach any new images if present
        if params[:product][:images].present?
          @admin_product.images.attach(params[:product][:images])
        end

        format.html { redirect_to admin_products_path, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @admin_product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/products/1 or /admin/products/1.json
  def destroy
    @admin_product.destroy!

    respond_to do |format|
      format.html { redirect_to admin_products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def destroy_image
    @product = Product.find(params[:product_id])
    image = @product.images.find(params[:id])
    image.purge

    respond_to do |format|
      format.html { redirect_to edit_admin_product_path(@product), notice: "Image has been deleted" }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_product
    @admin_product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def admin_product_params
    params.require(:product).permit(:title, :description, :price, :active, :category_id, images: [])
  end
end
