# frozen_string_literal: true

require "spec_helper"

RSpec.describe CommentPolicy, type: :policy do
  subject { described_class }

  let(:user) { build_stubbed(:user) }
  let(:disabled_user) { build_stubbed(:user, comments_disabled: true) }
  let(:own_draft) { build_stubbed(:comment, user:, published: false) }
  let(:disabled_users_draft) { build_stubbed(:comment, user: disabled_user, published: false) }
  let(:own_published) { build_stubbed(:comment, user:, published: true) }
  let(:someone_elses_draft) { build_stubbed(:comment, user: build_stubbed(:user), published: false) }

  permissions :create? do
    it { is_expected.to permit(user, build_stubbed(:comment)) }
    it { is_expected.not_to permit(disabled_user, build_stubbed(:comment)) }
  end

  context "when changing or sending a draft" do
    # Drafts started before commenting was disabled can't be changed or sent
    %i[update? publish?].each do |action|
      permissions action do
        it { is_expected.to permit(user, own_draft) }
        it { is_expected.not_to permit(disabled_user, disabled_users_draft) }
        it { is_expected.not_to permit(user, own_published) }
        it { is_expected.not_to permit(user, someone_elses_draft) }
      end
    end
  end

  context "when looking at or clearing a draft" do
    # Still allowed after commenting is disabled
    %i[preview? destroy?].each do |action|
      permissions action do
        it { is_expected.to permit(user, own_draft) }
        it { is_expected.to permit(disabled_user, disabled_users_draft) }
        it { is_expected.not_to permit(user, someone_elses_draft) }
      end
    end
  end
end
