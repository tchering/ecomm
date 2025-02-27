require "rails_helper"

RSpec.describe OrderStatusUpdateJob, type: :job do
  include ActiveJob::TestHelper

  let(:order) { create(:order) }
  let(:mail) { double("mail", deliver_now: true) }

  before do
    allow(OrderMailer).to receive(:status_update).and_return(mail)
  end

  it "queues the job" do
    expect {
      OrderStatusUpdateJob.perform_later(order)
    }.to have_enqueued_job(OrderStatusUpdateJob)
        .with(order)
        .on_queue("mailers")
  end

  it "sends a status update email" do
    expect(OrderMailer).to receive(:status_update).with(order).and_return(mail)
    expect(mail).to receive(:deliver_now)

    perform_enqueued_jobs do
      OrderStatusUpdateJob.perform_later(order)
    end
  end

  it "handles errors gracefully" do
    allow(OrderMailer).to receive(:status_update).and_raise(StandardError.new("Test error"))

    expect {
      perform_enqueued_jobs do
        OrderStatusUpdateJob.perform_later(order)
      end
    }.not_to raise_error
  end
end
