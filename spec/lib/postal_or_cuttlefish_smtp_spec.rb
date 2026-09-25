# frozen_string_literal: true

require "spec_helper"

describe PostalOrCuttlefishSmtp do
  let(:cuttlefish) { { address: "cuttlefish.example.com", port: 2525, user_name: "cuttlefish-user" } }
  let(:planningalerts) { { address: "postal.example.com", port: 2525, user_name: "planningalerts-user" } }
  let(:planningalerts_comments) { { address: "postal.example.com", port: 2525, user_name: "planningalerts-comments-user" } }
  let(:settings) do
    { cuttlefish:, postal: { planningalerts:, planningalerts_comments: } }
  end
  let(:mail) { Mail.new(to: "someone@example.com", from: "contact@planningalerts.org.au", subject: "Hello") }
  let(:smtp) { instance_double(Mail::SMTP, deliver!: nil) }

  before do
    allow(Mail::SMTP).to receive(:new).and_return(smtp)
  end

  def deliver(extra_settings = {})
    described_class.new(settings.merge(extra_settings)).deliver!(mail)
  end

  context "when the postal_smtp flag is not registered" do
    it "delivers through cuttlefish" do
      deliver
      expect(Mail::SMTP).to have_received(:new).with(cuttlefish)
      expect(smtp).to have_received(:deliver!).with(mail)
    end
  end

  context "when the postal_smtp flag is off" do
    before { Flipper.disable(:postal_smtp) }

    it "delivers through cuttlefish" do
      deliver
      expect(Mail::SMTP).to have_received(:new).with(cuttlefish)
    end

    it "ignores which postal mail server the mailer asked for" do
      deliver(mail_server: :planningalerts_comments)
      expect(Mail::SMTP).to have_received(:new).with(cuttlefish)
    end
  end

  context "when the postal_smtp flag is on" do
    before { Flipper.enable(:postal_smtp) }

    it "delivers through the planningalerts mail server by default" do
      deliver
      expect(Mail::SMTP).to have_received(:new).with(planningalerts)
      expect(smtp).to have_received(:deliver!).with(mail)
    end

    it "delivers through the mail server the mailer asked for" do
      deliver(mail_server: :planningalerts_comments)
      expect(Mail::SMTP).to have_received(:new).with(planningalerts_comments)
    end

    it "refuses a mail server it has no credentials for" do
      expect { deliver(mail_server: :morph) }.to raise_error(ArgumentError, /morph/)
      expect(Mail::SMTP).not_to have_received(:new)
    end
  end

  it "keeps the settings action mailer gave it" do
    expect(described_class.new(settings).settings).to eq(settings)
  end
end
