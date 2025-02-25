class Admin::ReviewsController < AdminController
  before_action :set_review, only: [:show, :update, :destroy, :approve, :reject]
  layout "admin"

  def index
    @status = params[:status] || "all"

    @reviews = case @status
      when "pending"
        Review.where(approved: nil)
      when "approved"
        Review.where(approved: true)
      when "rejected"
        Review.where(approved: false)
      else
        Review.all
      end

    @reviews = @reviews.includes(:user, :product).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
  end

  def update
    if @review.update(review_params)
      redirect_to admin_review_path(@review), notice: "Review was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to admin_reviews_path, notice: "Review was successfully deleted."
  end

  def approve
    @review.update(approved: true)
    redirect_to admin_reviews_path, notice: "Review was successfully approved."
  end

  def reject
    @review.update(approved: false)
    redirect_to admin_reviews_path, notice: "Review was successfully rejected."
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:title, :body, :rating, :approved)
  end
end
