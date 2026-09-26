# frozen_string_literal: true

require "spec_helper"

# The IdleBasicAuth middleware itself lives in config/application.rb, alongside
# PlausibleProxy, because that file is excluded from Sorbet and RuboCop and so
# escapes the `# typed: strict` requirement that applies under app/ and lib/.
#
# Two paths are used as probes throughout:
#
# - /donate is a bare redirect route, so it reaches the Rails stack without
#   touching the database or rendering a view.
# - /robots.txt is served by ActionDispatch::Static straight out of public/.
#   Covering it is the whole reason the middleware is registered with
#   `insert_before 0` rather than `use`: appended to the end of the stack it
#   would sit behind ActionDispatch::Static and leak every static file.
describe "IdleBasicAuth" do
  let(:username) { "idle" }
  let(:password) { "not-the-real-password" }

  def auth_header(user, pass)
    {
      "HTTP_AUTHORIZATION" =>
        ActionController::HttpAuthentication::Basic.encode_credentials(user, pass)
    }
  end

  def stub_credentials(user, pass)
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig)
      .with(:idle_basic_auth, :username).and_return(user)
    allow(Rails.application.credentials).to receive(:dig)
      .with(:idle_basic_auth, :password).and_return(pass)
  end

  # Save and restore the real environment, the way
  # spec/lib/tasks/planningalerts_rake_spec.rb does for REASON.
  def with_env(values)
    originals = values.keys.index_with { |k| ENV.fetch(k, nil) }
    values.each { |k, v| ENV[k] = v }
    yield
  ensure
    originals&.each do |k, v|
      v.nil? ? ENV.delete(k) : ENV[k] = v
    end
  end

  context "when credentials are configured and the host is www-idle" do
    before { stub_credentials(username, password) }

    it "challenges a request with no credentials" do
      get "https://www-idle.planningalerts.org.au/donate"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["www-authenticate"]).to match(/\ABasic realm="/)
    end

    it "challenges a request with the wrong password" do
      get "https://www-idle.planningalerts.org.au/donate",
          headers: auth_header(username, "wrong")

      expect(response).to have_http_status(:unauthorized)
    end

    it "challenges a request with the wrong username" do
      get "https://www-idle.planningalerts.org.au/donate",
          headers: auth_header("wrong", password)

      expect(response).to have_http_status(:unauthorized)
    end

    it "challenges a request for a static file in public/" do
      get "https://www-idle.planningalerts.org.au/robots.txt"

      expect(response).to have_http_status(:unauthorized)
    end

    it "lets a correctly authenticated request through to the app" do
      get "https://www-idle.planningalerts.org.au/donate",
          headers: auth_header(username, password)

      expect(response).to have_http_status(:moved_permanently)
    end

    it "lets a correctly authenticated request through to a static file" do
      get "https://www-idle.planningalerts.org.au/robots.txt",
          headers: auth_header(username, password)

      expect(response).to have_http_status(:ok)
    end

    it "matches the host regardless of case" do
      get "https://WWW-IDLE.planningalerts.org.au/donate"

      expect(response).to have_http_status(:unauthorized)
    end

    it "matches the host when it carries a port" do
      get "https://www-idle.planningalerts.org.au:3000/donate"

      expect(response).to have_http_status(:unauthorized)
    end

    # X-Forwarded-Host is client-supplied and passed through by the ALB, so
    # reading the host via Rack::Request#host (which prefers it) would let
    # anyone skip the challenge by naming a different host.
    it "ignores a spoofed X-Forwarded-Host" do
      get "https://www-idle.planningalerts.org.au/donate",
          headers: { "HTTP_X_FORWARDED_HOST" => "www.planningalerts.org.au" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when credentials are configured and the host is not www-idle" do
    before { stub_credentials(username, password) }

    it "leaves the live site alone" do
      get "https://www.planningalerts.org.au/donate"

      expect(response).to have_http_status(:moved_permanently)
    end

    it "leaves api-idle alone" do
      get "https://api-idle.planningalerts.org.au/donate"

      # Reaches the routes, which only serve the API on this host
      expect(response).to have_http_status(:not_found)
    end

    # The ALB health check sends the target's IP and port as the Host header,
    # so it never looks like www-idle and is never challenged.
    it "leaves a request addressed to the instance by IP alone" do
      get "http://10.0.0.7/donate"

      expect(response).to have_http_status(:moved_permanently)
    end

    it "does not challenge a static file on the live site" do
      get "https://www.planningalerts.org.au/robots.txt"

      expect(response).to have_http_status(:ok)
    end
  end

  context "when credentials come from the environment" do
    before do
      allow(Rails.application.credentials).to receive(:dig).and_call_original
      allow(Rails.application.credentials).to receive(:dig)
        .with(:idle_basic_auth, :username).and_return(nil)
      allow(Rails.application.credentials).to receive(:dig)
        .with(:idle_basic_auth, :password).and_return(nil)
    end

    it "accepts the environment credentials" do
      with_env("IDLE_BASIC_AUTH_USERNAME" => username,
               "IDLE_BASIC_AUTH_PASSWORD" => password) do
        get "https://www-idle.planningalerts.org.au/donate",
            headers: auth_header(username, password)
      end

      expect(response).to have_http_status(:moved_permanently)
    end

    it "still challenges the wrong environment credentials" do
      with_env("IDLE_BASIC_AUTH_USERNAME" => username,
               "IDLE_BASIC_AUTH_PASSWORD" => password) do
        get "https://www-idle.planningalerts.org.au/donate",
            headers: auth_header(username, "wrong")
      end

      expect(response).to have_http_status(:unauthorized)
    end
  end

  # Failing open here would leave www-idle silently unprotected, which is the
  # thing this middleware exists to prevent, so a missing configuration locks
  # the idle environment rather than opening it.
  context "when no credentials are configured anywhere" do
    before do
      allow(Rails.application.credentials).to receive(:dig).and_call_original
      allow(Rails.application.credentials).to receive(:dig)
        .with(:idle_basic_auth, :username).and_return(nil)
      allow(Rails.application.credentials).to receive(:dig)
        .with(:idle_basic_auth, :password).and_return(nil)
    end

    it "challenges every request to www-idle" do
      with_env("IDLE_BASIC_AUTH_USERNAME" => nil,
               "IDLE_BASIC_AUTH_PASSWORD" => nil) do
        get "https://www-idle.planningalerts.org.au/donate"
      end

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects any credentials offered" do
      with_env("IDLE_BASIC_AUTH_USERNAME" => nil,
               "IDLE_BASIC_AUTH_PASSWORD" => nil) do
        get "https://www-idle.planningalerts.org.au/donate",
            headers: auth_header("", "")
      end

      expect(response).to have_http_status(:unauthorized)
    end

    it "leaves the live site alone" do
      with_env("IDLE_BASIC_AUTH_USERNAME" => nil,
               "IDLE_BASIC_AUTH_PASSWORD" => nil) do
        get "https://www.planningalerts.org.au/donate"
      end

      expect(response).to have_http_status(:moved_permanently)
    end
  end
end
