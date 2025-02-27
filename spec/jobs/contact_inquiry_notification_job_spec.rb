require "rails_helper"

RSpec.describe ContactInquiryNotificationJob, type: :job do
  include ActiveJob::TestHelper

  let(:inquiry) { create(:contact_inquiry) }
  let(:mail) { double("mail", deliver_now: true) }

  before do
    allow(ContactMailer).to receive(:admin_notification).and_return(mail)
  end

  it "queues the job" do
    expect {
      ContactInquiryNotificationJob.perform_later(inquiry)
    }.to have_enqueued_job(ContactInquiryNotificationJob)
        .with(inquiry)
        .on_queue("mailers")
  end

  it "sends an admin notification email" do
    expect(ContactMailer).to receive(:admin_notification).with(inquiry).and_return(mail)
    expect(mail).to receive(:deliver_now)

    perform_enqueued_jobs do
      ContactInquiryNotificationJob.perform_later(inquiry)
    end
  end

  it "handles errors gracefully" do
    allow(ContactMailer).to receive(:admin_notification).and_raise(StandardError.new("Test error"))

    expect {
      perform_enqueued_jobs do
        ContactInquiryNotificationJob.perform_later(inquiry)
      end
    }.not_to raise_error
  end
end
