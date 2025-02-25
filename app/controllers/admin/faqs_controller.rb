class Admin::FaqsController < AdminController
  before_action :set_faq, only: [:show, :edit, :update, :destroy]
  layout "admin"

  def index
    @faqs = Faq.all.order(:category, :question)
  end

  def show
  end

  def new
    @faq = Faq.new
  end

  def edit
  end

  def create
    @faq = Faq.new(faq_params)

    if @faq.save
      redirect_to admin_faqs_path, notice: "FAQ was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: "FAQ was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @faq.destroy
    redirect_to admin_faqs_path, notice: "FAQ was successfully deleted.", status: :see_other
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer, :category)
  end
end
