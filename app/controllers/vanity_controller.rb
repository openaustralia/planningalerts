# frozen_string_literal: true

class VanityController < ApplicationController
  include Vanity::Rails::Dashboard
  layout false
  # Only allow admin users access to these pages
  before_filter :authenticate_user!, except: :add_participant
end
