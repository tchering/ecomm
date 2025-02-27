require "rails_helper"

RSpec.describe NewsletterDeliveryJob, type: :job do
  include ActiveJob::TestHelper

  let(:newsletter) { create(:newsletter) }
  let(:subscription) { create(:newsletter_subscription) }
  let(:mail) { double("mail", deliver_now: true) }

  before do
    allow(NewsletterMailer).to receive(:newsletter_email).and_return(mail)
  end

  it "queues the job" do
    expect {
      NewsletterDeliveryJob.perform_later(newsletter, subscription)
    }.to have_enqueued_job(NewsletterDeliveryJob)
        .with(newsletter, subscription)
        .on_queue("mailers")
  end

  it "sends a newsletter email" do
    expect(NewsletterMailer).to receive(:newsletter_email).with(newsletter, subscription).and_return(mail)
    expect(mail).to receive(:deliver_now)

    perform_enqueued_jobs do
      NewsletterDeliveryJob.perform_later(newsletter, subscription)
    end
  end

  it "handles errors gracefully" do
    allow(NewsletterMailer).to receive(:newsletter_email).and_raise(StandardError.new("Test error"))

    expect {
      perform_enqueued_jobs do
        NewsletterDeliveryJob.perform_later(newsletter, subscription)
      end
    }.not_to raise_error
  end
end
