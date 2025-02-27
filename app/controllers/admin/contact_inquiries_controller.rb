module Admin
  class ContactInquiriesController < AdminController
    before_action :set_inquiry, only: [:show, :respond, :mark_as_resolved, :mark_as_spam]

    # List all inquiries
    def index
      @inquiries = ContactInquiry.all.order(created_at: :desc).page(params[:page]).per(20)

      # Filter by status if provided
      if params[:status].present?
        @inquiries = @inquiries.where(status: params[:status])
      end
    end

    # Show inquiry details
    def show
      @responses = @inquiry.contact_responses.order(created_at: :asc)
      @response = ContactResponse.new(contact_inquiry: @inquiry)
    end

    # Respond to inquiry
    def respond
      @response = ContactResponse.new(response_params)
      @response.user = current_admin_user
      @response.contact_inquiry = @inquiry

      if @response.save
        # Send response email
        ContactMailer.admin_response(@response).deliver_later

        # Mark as resolved if requested
        @inquiry.mark_as_resolved! if params[:mark_as_resolved].present?

        redirect_to admin_contact_inquiry_path(@inquiry), notice: "Response was sent successfully."
      else
        @responses = @inquiry.contact_responses.order(created_at: :asc)
        render :show, status: :unprocessable_entity
      end
    end

    # Mark inquiry as resolved
    def mark_as_resolved
      @inquiry.mark_as_resolved!
      redirect_to admin_contact_inquiries_path, notice: "Inquiry was marked as resolved."
    end

    # Mark inquiry as spam
    def mark_as_spam
      @inquiry.mark_as_spam!
      redirect_to admin_contact_inquiries_path, notice: "Inquiry was marked as spam."
    end

    private

    def set_inquiry
      @inquiry = ContactInquiry.find(params[:id])
    end

    def response_params
      params.require(:contact_response).permit(:message)
    end
  end
end
