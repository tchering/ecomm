class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
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

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product), notice: "Thank you for your review! It will be published after moderation."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to product_path(@product), notice: "Your review was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to product_path(@product), notice: "Your review was successfully deleted."
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
      redirect_to product_path(@product), alert: "You are not authorized to modify this review."
    end
  end
end
