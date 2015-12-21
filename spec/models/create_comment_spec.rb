require 'spec_helper'

describe CreateComment do
  describe "#save_comment" do
    let(:application) { create(:application, id: 1) }
    let(:create_comment_form) do
      build(:create_comment, application_id: 1,
                             comment_for: nil,
                             text: "Testing testing 1 2 3")
    end

    context "that can be sent to a councillor" do
      before :each do
        allow(create_comment_form).to receive(:has_for_options?).and_return(true)
      end

      it "is invalid without specificfy who it is for" do
        expect(create_comment_form).to_not be_valid
        expect(create_comment_form.save_comment).to be_nil
      end

      context "when it is for the planning authority" do
        before do
          create_comment_form.comment_for = "planning authority"
        end

        it { expect(create_comment_form).to be_valid }

        it "creates the comment with the correct attributes" do
          VCR.use_cassette('planningalerts') do
            expect(create_comment_form.save_comment).to be_an_instance_of(Comment)
            expect(application.comments.first.text).to eq "Testing testing 1 2 3"
          end
        end
      end

      context "when it is for a councillor" do
        before do
          VCR.use_cassette('planningalerts') { create(:councillor, id: 3) }
          create_comment_form.comment_for = 3
        end

        it { expect(create_comment_form).to be_valid }

        it "creates the comment with the correct attributes" do
          VCR.use_cassette('planningalerts') do
            expect(create_comment_form.save_comment).to be_an_instance_of(Comment)
            expect(application.comments.first.text).to eq "Testing testing 1 2 3"
          end
        end
      end

      context "when it is for an unknown councillor" do
        before do
          VCR.use_cassette('planningalerts') { create(:councillor, id: 3) }
          create_comment_form.comment_for = 5
        end

        it { expect(create_comment_form).to be_valid }
        it "raises an error" do
          expect { create_comment_form.save_comment }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "that can’t be sent to a councillor" do
      before do
         allow(create_comment_form).to receive(:has_for_options?).and_return(false)
      end

      it "is valid without specificing who it is for" do
        expect(create_comment_form).to be_valid
      end

      it "creates the comment with the correct attributes" do
        VCR.use_cassette('planningalerts') do
          expect(create_comment_form.save_comment).to be_an_instance_of(Comment)
          expect(application.comments.first.text).to eq "Testing testing 1 2 3"
        end
      end
    end
  end

  describe "#has_for_options?" do
    let(:create_comment_form) do
      build(:create_comment, application_id: 1)
    end

    before :each do
      @application = VCR.use_cassette('planningalerts') { create(:application, id: 1) }
    end

    context "when the writing to councillors feature is not enabled" do
      context "and Default theme is active" do
        before :each do
          create_comment_form.theme = "default"
        end

        context "and there are councillors" do
          it { expect(create_comment_form.has_for_options?).to eq false }
        end

        context "and there are not councillors" do
          it { expect(create_comment_form.has_for_options?).to eq false }
        end
      end

      context "and the NSW theme is active" do
        before :each do
          create_comment_form.theme = "nsw"
        end

        context "and there are councillors" do
          before do
            create(:councillor, authority: @application.authority)
          end

          it { expect(create_comment_form.has_for_options?).to eq false }
        end

        context "and there are not councillors" do
          it { expect(create_comment_form.has_for_options?).to eq false }
        end
      end
    end

    context "when the writing to councillors feature is enabled" do
      around do |test|
        with_modified_env COUNCILLORS_ENABLED: 'true' do
          test.run
        end
      end

      context "and Default theme is active" do
        before :each do
          create_comment_form.theme = "default"
        end

        context "and there are councillors" do
          before do
            create(:councillor, authority: @application.authority)
          end

          it { expect(create_comment_form.has_for_options?).to eq true }
        end

        context "and there are not councillors" do
          it { expect(create_comment_form.has_for_options?).to eq false }
        end
      end

      context "and the NSW theme is active" do
        before :each do
          create_comment_form.theme = "nsw"
        end

        context "and there are councillors" do
          it { expect(create_comment_form.has_for_options?).to eq false }
        end

        context "and there are not councillors" do
          it { expect(create_comment_form.has_for_options?).to eq false }
        end
      end
    end
  end

  context "when comment_for is nil" do
    let(:create_comment_form) { build(:create_comment, comment_for: nil) }

    it { expect(create_comment_form.for_planning_authority?).to eq true }
    it { expect(create_comment_form.for_councillor?).to eq false }
  end

  context "when comment_for is 'planning authority'" do
    let(:create_comment_form) { build(:create_comment, comment_for: "planning authority") }

    it { expect(create_comment_form.for_planning_authority?).to eq true }
    it { expect(create_comment_form.for_councillor?).to eq false }
  end

  context "when comment_for is an integer" do
    let(:create_comment_form) { build(:create_comment, comment_for: 2) }

    it { expect(create_comment_form.for_planning_authority?).to eq false }
    it { expect(create_comment_form.for_councillor?).to eq true }
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
