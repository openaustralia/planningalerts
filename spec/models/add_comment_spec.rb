require "spec_helper"

describe AddComment do
  describe "#save_comment" do
    let(:application) { VCR.use_cassette("planningalerts") { create(:application) } }
    let(:add_comment_form) do
      build(:add_comment, application: application,
                          comment_for: nil,
                          text: "Testing testing 1 2 3")
    end

    context "that can be sent to a councillor" do
      before :each do
        allow(add_comment_form).to receive(:could_be_for_councillor?).and_return(true)
      end

      it "is invalid without specificfy who it is for" do
        expect(add_comment_form).to_not be_valid
        expect(add_comment_form.save_comment).to be_nil
      end

      context "when it is for the planning authority" do
        before do
          add_comment_form.comment_for = "planning authority"
        end

        it { expect(add_comment_form).to be_valid }

        it "creates the comment with the correct attributes" do
          VCR.use_cassette("planningalerts") do
            expect(add_comment_form.save_comment).to be_an_instance_of(Comment)
            expect(application.comments.first.text).to eq "Testing testing 1 2 3"
          end
        end

        context "and there is no address" do
          before { add_comment_form.address = nil }

          it { expect(add_comment_form).to_not be_valid }
        end

        context "and an address is present" do
          before { add_comment_form.address = "64 Fake st" }

          it { expect(add_comment_form).to be_valid }
        end
      end

      context "when it is for a councillor" do
        before do
          VCR.use_cassette("planningalerts") { create(:councillor, id: 3) }
          add_comment_form.comment_for = 3
        end

        it { expect(add_comment_form).to be_valid }

        it "creates the comment with the correct attributes" do
          VCR.use_cassette("planningalerts") do
            expect(add_comment_form.save_comment).to be_an_instance_of(Comment)
            expect(application.comments.first.text).to eq "Testing testing 1 2 3"
          end
        end

        context "and there is no address" do
          before { add_comment_form.address = nil }

          it { expect(add_comment_form).to be_valid }
        end

        context "and an address is present" do
          before { add_comment_form.address = "64 Fake st" }

          it "removes it before saving the comment" do
            expect(add_comment_form).to be_valid

            VCR.use_cassette("planningalerts") do
              expect(add_comment_form.save_comment).to be_an_instance_of(Comment)
              expect(application.comments.first.address).to be_nil
            end
          end
        end
      end

      context "when it is for an unknown councillor" do
        before do
          VCR.use_cassette("planningalerts") { create(:councillor, id: 3) }
          add_comment_form.comment_for = 5
        end

        it { expect(add_comment_form).to be_valid }
        it "raises an error" do
          expect { add_comment_form.save_comment }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "that can’t be sent to a councillor" do
      before do
        allow(add_comment_form).to receive(:could_be_for_councillor?).and_return(false)
      end

      it "is valid without specificing who it is for" do
        expect(add_comment_form).to be_valid
      end

      it "creates the comment with the correct attributes" do
        VCR.use_cassette("planningalerts") do
          expect(add_comment_form.save_comment).to be_an_instance_of(Comment)
          expect(application.comments.first.text).to eq "Testing testing 1 2 3"
        end
      end

      context "and there is no address" do
        before { add_comment_form.address = nil }

        it { expect(add_comment_form).to_not be_valid }
      end

      context "and an address is present" do
        before { add_comment_form.address = "64 Fake st" }

        it { expect(add_comment_form).to be_valid }
      end
    end
  end

  describe "#could_be_for_councillor?" do
    let(:application) { VCR.use_cassette("planningalerts") { create(:application) } }
    let(:add_comment_form) do
      build(:add_comment, application: application)
    end

    context "and Default theme is active" do
      before :each do
        add_comment_form.theme = "default"
      end

      context "and there are contactable councillors" do
        before do
          allow(application).to receive(:councillors_available_for_contact)
            .and_return [create(:councillor, authority: application.authority)]
        end

        it { expect(add_comment_form.could_be_for_councillor?).to eq true }
      end

      context "and there are no contactable councillors" do
        before do
          allow(application).to receive(:councillors_available_for_contact)
            .and_return nil
        end

        it { expect(add_comment_form.could_be_for_councillor?).to eq false }
      end
    end

    context "and the NSW theme is active" do
      before :each do
        add_comment_form.theme = "nsw"
      end

      context "and there are contactable councillors" do
        before do
          allow(application).to receive(:councillors_available_for_contact)
            .and_return [create(:councillor, authority: application.authority)]
        end

        it { expect(add_comment_form.could_be_for_councillor?).to eq false }
      end

      context "and there are no contactable councillors" do
        before do
          allow(application).to receive(:councillors_available_for_contact)
            .and_return nil
        end

        it { expect(add_comment_form.could_be_for_councillor?).to eq false }
      end
    end
  end

  context "when comment_for is nil" do
    let(:add_comment_form) do
      build(:add_comment, comment_for: nil, address: "64 Fake st")
    end

    it { expect(add_comment_form.for_planning_authority?).to eq true }
    it { expect(add_comment_form.for_councillor?).to eq false }

    it "doesn't remove the address" do
      add_comment_form.remove_address_if_for_councillor

      expect(add_comment_form.address).to eq "64 Fake st"
    end
  end

  context "when comment_for is 'planning authority'" do
    let(:add_comment_form) do
      build(:add_comment, comment_for: "planning authority", address: "64 Fake st")
    end

    it { expect(add_comment_form.for_planning_authority?).to eq true }
    it { expect(add_comment_form.for_councillor?).to eq false }

    it "doesn't remove the address" do
      add_comment_form.remove_address_if_for_councillor

      expect(add_comment_form.address).to eq "64 Fake st"
    end
  end

  context "when comment_for is an integer" do
    let(:add_comment_form) do
      build(:add_comment, comment_for: 2, address: "64 Fake st")
    end

    it { expect(add_comment_form.for_planning_authority?).to eq false }
    it { expect(add_comment_form.for_councillor?).to eq true }

    it "removes the address" do
      add_comment_form.remove_address_if_for_councillor

      expect(add_comment_form.address).to be_nil
    end
  end
end
