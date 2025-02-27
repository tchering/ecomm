module Admin
  class NewslettersController < AdminController
    before_action :set_newsletter, only: [:show, :edit, :update, :destroy, :send_now]

    # List all newsletters
    def index
      @newsletters = Newsletter.all.order(created_at: :desc).page(params[:page]).per(10)

      # Filter by status if provided
      if params[:status].present?
        @newsletters = @newsletters.where(status: params[:status])
      end
    end

    # Show newsletter details
    def show
    end

    # New newsletter form
    def new
      @newsletter = Newsletter.new
    end

    # Create newsletter
    def create
      @newsletter = Newsletter.new(newsletter_params)

      if @newsletter.save
        if params[:commit] == "Save & Send Now"
          @newsletter.send_now!
          redirect_to admin_newsletters_path, notice: "Newsletter was created and is being sent."
        elsif params[:commit] == "Schedule"
          delivery_time = Time.zone.parse(params[:scheduled_time]) if params[:scheduled_time].present?
          if delivery_time && delivery_time > Time.current
            @newsletter.schedule_delivery(delivery_time)
            redirect_to admin_newsletters_path, notice: "Newsletter was scheduled for #{delivery_time.strftime("%B %d, %Y at %I:%M %p")}."
          else
            @newsletter.update(status: :draft)
            redirect_to edit_admin_newsletter_path(@newsletter), alert: "Invalid scheduled time. Please select a future time."
          end
        else
          redirect_to admin_newsletters_path, notice: "Newsletter was successfully created as a draft."
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
        if params[:commit] == "Save & Send Now"
          @newsletter.send_now!
          redirect_to admin_newsletters_path, notice: "Newsletter was updated and is being sent."
        elsif params[:commit] == "Schedule"
          delivery_time = Time.zone.parse(params[:scheduled_time]) if params[:scheduled_time].present?
          if delivery_time && delivery_time > Time.current
            @newsletter.schedule_delivery(delivery_time)
            redirect_to admin_newsletters_path, notice: "Newsletter was scheduled for #{delivery_time.strftime("%B %d, %Y at %I:%M %p")}."
          else
            redirect_to edit_admin_newsletter_path(@newsletter), alert: "Invalid scheduled time. Please select a future time."
          end
        else
          redirect_to admin_newsletters_path, notice: "Newsletter was successfully updated."
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

    # Send newsletter now
    def send_now
      @newsletter.send_now!
      redirect_to admin_newsletters_path, notice: "Newsletter is being sent."
    end

    private

    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    def newsletter_params
      params.require(:newsletter).permit(:title, :content, :status)
    end
  end
end
