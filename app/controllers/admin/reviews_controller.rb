module Admin
  class ReviewsController < AdminController
    before_action :set_review, only: [:show, :update, :destroy, :approve, :reject]

    def index
      @reviews = Review.includes(:user, :product)
                      .order(created_at: :desc)
                      .page(params[:page])

      @reviews = case params[:filter]
                when 'pending'
                  @reviews.where(approved: false)
                when 'approved'
                  @reviews.where(approved: true)
                else
                  @reviews
                end
    end

    def show
    end

    def update
      if @review.update(review_params)
        redirect_to admin_review_path(@review), notice: 'Review was successfully updated.'
      else
        render :show
      end
    end

    def destroy
      @review.destroy
      redirect_to admin_reviews_path, notice: 'Review was successfully deleted.'
    end

    def approve
      @review.update(approved: true)
      ReviewMailer.review_approved(@review).deliver_later
      redirect_to admin_reviews_path, notice: 'Review was successfully approved.'
    end

    def reject
      @review.update(approved: false)
      ReviewMailer.review_rejected(@review).deliver_later
      redirect_to admin_reviews_path, notice: 'Review was successfully rejected.'
    end

    private

    def set_review
      @review = Review.find(params[:id])
    end

    def review_params
      params.require(:review).permit(:approved, :title, :body, :rating)
    end
  end
end
