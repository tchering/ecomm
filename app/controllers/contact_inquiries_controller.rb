class ContactInquiriesController < ApplicationController
  # Skip authentication for these actions
  skip_before_action :authenticate_user!, raise: false

  # Show the contact form
  def new
    @inquiry = ContactInquiry.new
  end

  # Create a new inquiry
  def create
    @inquiry = ContactInquiry.new(inquiry_params)

    respond_to do |format|
      if @inquiry.save
        # Process inquiry in background
        ProcessContactInquiryJob.perform_later(@inquiry.id)

        format.html { redirect_to root_path, notice: "Thank you for your inquiry! We'll get back to you soon." }
        format.json { render json: { success: true, message: "Inquiry submitted successfully" }, status: :created }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @inquiry.errors.full_messages }, status: :unprocessable_entity }
        format.js
      end
    end
  end

  private

  def inquiry_params
    params.require(:contact_inquiry).permit(:name, :email, :subject, :message)
  end
end
