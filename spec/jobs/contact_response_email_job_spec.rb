require "rails_helper"

RSpec.describe ContactResponseEmailJob, type: :job do
  include ActiveJob::TestHelper

  let(:response) { create(:contact_response) }
  let(:mail) { double("mail", deliver_now: true) }

  before do
    allow(ContactMailer).to receive(:inquiry_response).and_return(mail)
  end

  it "queues the job" do
    expect {
      ContactResponseEmailJob.perform_later(response)
    }.to have_enqueued_job(ContactResponseEmailJob)
        .with(response)
        .on_queue("mailers")
  end

  it "sends a response email" do
    expect(ContactMailer).to receive(:inquiry_response).with(response).and_return(mail)
    expect(mail).to receive(:deliver_now)

    perform_enqueued_jobs do
      ContactResponseEmailJob.perform_later(response)
    end
  end

  it "handles errors gracefully" do
    allow(ContactMailer).to receive(:inquiry_response).and_raise(StandardError.new("Test error"))

    expect {
      perform_enqueued_jobs do
        ContactResponseEmailJob.perform_later(response)
      end
    }.not_to raise_error
  end
end
