module Admin
  class NewslettersController < AdminController
    before_action :set_newsletter, only: [:show, :edit, :update, :destroy, :duplicate, :send_now, :preview]

    # List all newsletters
    def index
      @newsletters = Newsletter.recent.page(params[:page]).per(20)

      # Filter by status if provided
      if params[:status].present?
        @newsletters = @newsletters.where(status: params[:status])
      end
    end

    # Show newsletter details
    def show
      @recipients = @newsletter.newsletter_recipients.includes(:newsletter_subscription)
        .page(params[:page]).per(50)
    end

    # New newsletter form
    def new
      @newsletter = Newsletter.new
    end

    # Create newsletter
    def create
      @newsletter = Newsletter.new(newsletter_params)
      @newsletter.created_by = current_admin_user

      if @newsletter.save
        if params[:send_now]
          @newsletter.send_now!
          redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter is being sent."
        else
          redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter was successfully created."
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    # Edit newsletter form
    def edit
    end

    # Update newsletter
    def update
      if @newsletter.update(newsletter_params)
        if params[:send_now]
          @newsletter.send_now!
          redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter is being sent."
        else
          redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter was successfully updated."
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Delete newsletter
    def destroy
      @newsletter.destroy
      redirect_to admin_newsletters_path, notice: "Newsletter was successfully deleted."
    end

    def duplicate
      new_newsletter = @newsletter.duplicate
      redirect_to edit_admin_newsletter_path(new_newsletter), notice: "Newsletter was successfully duplicated."
    end

    # Send newsletter now
    def send_now
      if @newsletter.draft?
        @newsletter.send_now!
        redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter is being sent."
      else
        redirect_to admin_newsletter_path(@newsletter), alert: "Newsletter cannot be sent in its current state."
      end
    end

    def preview
      render layout: false
    end

    private

    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    def newsletter_params
      params.require(:newsletter).permit(
        :subject,
        :content,
        :preview_text,
        :scheduled_for,
        :status
      )
    end
  end
end
