class ApplicationMailer < ActionMailer::Base
  default from: "noreply@yourecommstore.com"
  layout "mailer"

  # Helper method to get admin email
  def admin_email
    "admin@yourecommstore.com"
  end
end
