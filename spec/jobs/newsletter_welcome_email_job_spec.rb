require "rails_helper"

RSpec.describe NewsletterWelcomeEmailJob, type: :job do
  include ActiveJob::TestHelper

  let(:subscription) { create(:newsletter_subscription) }
  let(:mail) { double("mail", deliver_now: true) }

  before do
    allow(NewsletterMailer).to receive(:welcome_email).and_return(mail)
  end

  it "queues the job" do
    expect {
      NewsletterWelcomeEmailJob.perform_later(subscription)
    }.to have_enqueued_job(NewsletterWelcomeEmailJob)
        .with(subscription)
        .on_queue("mailers")
  end

  it "sends a welcome email" do
    expect(NewsletterMailer).to receive(:welcome_email).with(subscription).and_return(mail)
    expect(mail).to receive(:deliver_now)

    perform_enqueued_jobs do
      NewsletterWelcomeEmailJob.perform_later(subscription)
    end
  end

  it "handles errors gracefully" do
    allow(NewsletterMailer).to receive(:welcome_email).and_raise(StandardError.new("Test error"))

    expect {
      perform_enqueued_jobs do
        NewsletterWelcomeEmailJob.perform_later(subscription)
      end
    }.not_to raise_error
  end
end
