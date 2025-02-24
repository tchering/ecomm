class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_product
  before_action :set_review, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @reviews = @product.reviews.approved.includes(:user).page(params[:page])

    # Apply filters based on params
    @reviews = case params[:sort]
      when "highest_rating"
        @reviews.highest_rating
      when "lowest_rating"
        @reviews.lowest_rating
      else
        @reviews.most_recent
      end

    @reviews = @reviews.where(rating: params[:rating]) if params[:rating].present?
  end

  def show
    @review = @product.reviews.find(params[:id])
  end

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    respond_to do |format|
      if @review.save
        format.html { redirect_to store_path(@product), notice: "Thank you for your review! It will be published after moderation." }
        format.turbo_stream {
          redirect_to product_review_path(@product, @review), notice: "Thank you for your review! It will be published after moderation."
        }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "new_review_form",
            partial: "reviews/form",
            locals: { review: @review, product: @product },
          )
        }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to product_review_path(@product, @review), notice: "Your review was successfully updated." }
        format.turbo_stream {
          redirect_to product_review_path(@product, @review), notice: "Your review was successfully updated."
        }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "edit_review_form_#{@review.id}",
            partial: "reviews/form",
            locals: { review: @review, product: @product },
          )
        }
      end
    end
  end

  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to product_reviews_path(@product), notice: "Your review was successfully deleted." }
      format.turbo_stream {
        redirect_to product_reviews_path(@product), notice: "Your review was successfully deleted."
      }
    end
  end

  # AJAX action for helpful/unhelpful votes
  def vote
    @review = Review.find(params[:id])
    vote_type = params[:vote_type]

    if vote_type == "helpful"
      @review.increment!(:helpful_votes)
    elsif vote_type == "unhelpful"
      @review.increment!(:unhelpful_votes)
    end

    respond_to do |format|
      format.json { render json: { helpful_score: @review.helpful_score } }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :title, :body, images: [])
  end

  def authorize_user!
    unless @review.can_be_modified_by?(current_user)
      redirect_to store_path(@product), alert: "You are not authorized to modify this review."
    end
  end
end
