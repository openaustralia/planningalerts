# frozen_string_literal: true

require "spec_helper"

# Covers the three states each protected form can be in: the flag off, the flag
# on but not enforcing (monitor mode), and enforcing.
describe "ALTCHA protection" do
  # These examples solve real challenges, so keep the work small.
  before { stub_const("CreateAltchaChallengeService::COST", 100) }

  let(:sign_up_params) do
    { user: { name: "Jane Citizen", email: "jane@example.com", password: "correct horse battery" } }
  end

  def enforce!
    Flipper.enable(:altcha)
    Flipper.enable(:altcha_enforce)
  end

  describe "creating an account" do
    context "when the altcha flag is off" do
      it "signs somebody up without any check, exactly as before" do
        expect { post user_registration_path, params: sign_up_params }
          .to change(User, :count).by(1)
      end
    end

    context "when the altcha flag is on but altcha_enforce is off" do
      before { Flipper.enable(:altcha) }

      it "lets a submission with no answer through, so nobody is turned away yet" do
        expect { post user_registration_path, params: sign_up_params }
          .to change(User, :count).by(1)
      end

      it "still counts the outcome, which is the point of monitor mode" do
        allow(Sentry.metrics).to receive(:count)

        post user_registration_path, params: sign_up_params

        expect(Sentry.metrics).to have_received(:count).with(
          "altcha.checks", hash_including(attributes: hash_including(outcome: "missing"))
        )
      end

      # Missing is the ordinary case here and would swallow the Sentry quota to
      # say what the counter above already says.
      it "doesn't raise a Sentry event for a missing answer" do
        allow(Sentry).to receive(:capture_message)

        post user_registration_path, params: sign_up_params

        expect(Sentry).not_to have_received(:capture_message)
      end
    end

    context "when altcha_enforce is on" do
      before { enforce! }

      it "rejects a submission with no answer" do
        expect { post user_registration_path, params: sign_up_params }
          .not_to change(User, :count)
      end

      it "shows the form again rather than a bare error page" do
        post user_registration_path, params: sign_up_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Please reload the page and try again")
      end

      it "keeps what was typed so it doesn't have to be typed again" do
        post user_registration_path, params: sign_up_params

        expect(response.body).to include("jane@example.com")
      end

      it "accepts a submission that solved the challenge" do
        params = sign_up_params.merge(altcha: solve_altcha_challenge)

        expect { post user_registration_path, params: }.to change(User, :count).by(1)
      end

      # params can be an array or a hash if the query string says so, and the
      # verification service only takes a string.
      it "rejects a payload that isn't even a string, rather than falling over" do
        params = sign_up_params.merge(altcha: %w[not a string])

        expect { post user_registration_path, params: }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "rejects an answer that has already been used" do
        payload = solve_altcha_challenge
        post user_registration_path, params: sign_up_params.merge(altcha: payload)

        second = sign_up_params.deep_merge(user: { email: "jo@example.com" }).merge(altcha: payload)
        expect { post user_registration_path, params: second }.not_to change(User, :count)
      end

      it "raises a Sentry event for a replay, which is worth knowing about" do
        payload = solve_altcha_challenge
        post user_registration_path, params: sign_up_params.merge(altcha: payload)
        allow(Sentry).to receive(:capture_message)

        second = sign_up_params.deep_merge(user: { email: "jo@example.com" }).merge(altcha: payload)
        post user_registration_path, params: second

        expect(Sentry).to have_received(:capture_message)
          .with(/replayed/, hash_including(level: :warning))
      end
    end
  end

  describe "asking for account activation" do
    let(:params) { { user: { email: "someone@example.com" } } }

    it "is unaffected when the altcha flag is off" do
      post(users_activation_path, params:)

      expect(response.body).not_to include("Please reload the page and try again")
    end

    it "is rejected without an answer when enforcing" do
      enforce!
      post(users_activation_path, params:)

      expect(response.body).to include("Please reload the page and try again")
    end

    it "goes through with a solved challenge when enforcing" do
      enforce!
      # An account that still needs activating has no password set. Built the
      # long way round, as spec/features/activate_account_spec.rb does.
      user = User.new(email: "someone@example.com", from_alert_or_comment: true, confirmed_at: Time.zone.now)
      user.skip_confirmation_notification!
      user.save!(validate: false)

      post users_activation_path, params: params.merge(altcha: solve_altcha_challenge)

      expect(response).to redirect_to(check_email_users_activation_url)
    end
  end

  describe "asking for a password reset" do
    let(:params) { { user: { email: "someone@example.com" } } }

    it "is rejected without an answer when enforcing" do
      enforce!
      post(user_password_path, params:)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Please reload the page and try again")
    end

    it "goes through with a solved challenge when enforcing" do
      enforce!
      create(:confirmed_user, email: "someone@example.com")

      post user_password_path, params: params.merge(altcha: solve_altcha_challenge)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "asking for confirmation instructions again" do
    let(:params) { { user: { email: "someone@example.com" } } }

    it "is rejected without an answer when enforcing" do
      enforce!
      post(user_confirmation_path, params:)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Please reload the page and try again")
    end
  end
end
