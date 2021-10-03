# typed: true
# frozen_string_literal: true

class ApplicationRedirect < ApplicationRecord
  belongs_to :redirect_application, class_name: "Application"
end
