require "spec_helper"

feature "Subscribing to donate monthly" do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(amount: 1, id: Donation.plan_id_on_stripe)
  end

  after { StripeMock.stop }

  given(:email) { "mary@local.org" }

  context "when no stripe plan is configured" do
    around do |test|
      with_modified_env STRIPE_PLAN_ID_FOR_DONATIONS: nil do
        test.run
      end
    end

    it "isn't possible without a stripe plan configured" do
      visit new_donation_path

      expect(page).to have_content "The page you were looking for doesn't exist."
    end
  end

  context "when a stripe plan is configured" do
    around do |test|
      with_modified_env STRIPE_PLAN_ID_FOR_DONATIONS: "foo-plan-1" do
        test.run
      end
    end

    it "isn't possible without javascript" do
      visit new_donation_path

      expect(page).to have_button("Donate each month", disabled: true)
      expect(page).to have_content "Our donation form requires javascript"
    end

    context "with javascript" do
      it "successfully", js: true do
        visit new_donation_path

        click_button "Donate $4 each month"

        fill_out_and_submit_stripe_card_form_with_email(email)

        expect(page).to have_content "Thank you for backing PlanningAlerts"
        expect(Donation.find_by!(email: email)).to be_paid
      end

      it "successfully at a higher rate", js: true do
        visit new_donation_path

        fill_in "Choose your contribution", with: 10
        click_button "Donate $10 each month"

        fill_out_and_submit_stripe_card_form_with_email(email)

        expect(page).to have_content "Thank you for backing PlanningAlerts"
        expect(Donation.find_by!(email: email)).to be_paid

        stripe_customer = Stripe::Customer.retrieve(Donation.find_by!(email: email).stripe_customer_id)
        subscription_quantity_on_stripe = stripe_customer.subscriptions.data.first.quantity

        expect(subscription_quantity_on_stripe).to eq "10"
      end

      context "but there is already a donation for this email" do
        before do
          create(:donation, email: email, stripe_plan_id: ENV['STRIPE_PLAN_ID_FOR_DONATIONS'])
        end

        it "the person gets helpful feedback", js: true do
          visit new_donation_path

          click_button "Donate $4 each month"

          fill_out_and_submit_stripe_card_form_with_email(email)

          expect(page).to have_content "Sorry, we weren't able to process your donation. Please email us at contact@planningalerts and we'll sort it out. Thanks for your support and patience."
          expect(page).to_not have_content "Thank you for backing PlanningAlerts"
          expect(Donation.count).to eql 1
        end
      end
    end
  end
end

def fill_out_and_submit_stripe_card_form_with_email(email)
  page.within_frame find("iframe.stripe_checkout_app") do
    fill_in "Email", with: email
    fill_in "Card number", with: "4242424242424242"
    fill_in "MM / YY", with: "1222"
    fill_in "CVC", with: "123"
  end

  token = StripeMock.create_test_helper.generate_card_token
  page.execute_script("document.querySelector('input[name=\"stripeToken\"]').setAttribute(\"value\", \"#{token}\");")
  page.execute_script("document.querySelector('input[name=\"stripeEmail\"]').setAttribute(\"value\", \"#{email}\");")
  page.execute_script("$('#donation-payment-form').submit();")
end
