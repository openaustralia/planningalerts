# typed: strict
# frozen_string_literal: true

class VanityController < ApplicationController
  include Vanity::Rails::Dashboard
  layout false
  # Only allow admin users access to these pages
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :authenticate_user!, except: :add_participant
  # rubocop:enable Rails/LexicallyScopedActionFilter
end
