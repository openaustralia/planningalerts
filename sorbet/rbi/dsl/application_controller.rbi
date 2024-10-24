# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `ApplicationController`.
# Please instead update this file by running `bin/tapioca dsl ApplicationController`.


class ApplicationController
  include GeneratedUrlHelpersModule
  include GeneratedPathHelpersModule

  sig { returns(HelperProxy) }
  def helpers; end

  module HelperMethods
    include ::ActionText::ContentHelper
    include ::ActionText::TagHelper
    include ::Split::Helper
    include ::Split::CombinedExperimentsHelper
    include ::ActionController::Base::HelperMethods
    include ::ActionView::Helpers::AssetUrlHelper
    include ::ActionView::Helpers::CaptureHelper
    include ::ActionView::Helpers::OutputSafetyHelper
    include ::ActionView::Helpers::TagHelper
    include ::ActionView::Helpers::ContentExfiltrationPreventionHelper
    include ::ActionView::Helpers::UrlHelper
    include ::ActionView::Helpers::AssetTagHelper
    include ::ActionView::Helpers::SanitizeHelper
    include ::ActionView::Helpers::TextHelper
    include ::ActionView::Helpers::FormTagHelper
    include ::ActionView::ModelNaming
    include ::ActionView::RecordIdentifier
    include ::ActionView::Helpers::FormHelper
    include ::Kernel
    include ::ApplicationHelper
    include ::Admin::ApplicationHelper
    include ::AlertMailerHelper
    include ::ActionView::Helpers::DateHelper
    include ::AlertsHelper
    include ::ApplicationsHelper
    include ::ActionDispatch::Routing::PolymorphicRoutes
    include ::ActionDispatch::Routing::UrlFor
    include ::GeneratedUrlHelpersModule
    include ::GeneratedPathHelpersModule
    include ::ApiHowtoHelper
    include ::AuthoritiesHelper
    include ::CommentsHelper
    include ::SignupHelper
    include ::StaticHelper
    include ::PreviewHelper
    include ::DeviseHelper
    include ::Pundit::Helper

    sig { params(record: T.untyped).returns(T.untyped) }
    def policy(record); end

    sig { params(scope: T.untyped).returns(T.untyped) }
    def pundit_policy_scope(scope); end

    sig { returns(T.untyped) }
    def pundit_user; end
  end

  class HelperProxy < ::ActionView::Base
    include HelperMethods
  end
end
