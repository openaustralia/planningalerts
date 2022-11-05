# typed: strict
# frozen_string_literal: true

class AlertsNewController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  sig { void }
  def index
    @alerts = T.let(T.must(current_user).alerts.active, T.nilable(ActiveRecord::AssociationRelation))
  end
end
