# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: true
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/atdis/all/atdis.rbi
#
# atdis-0.4.1

module Atdis
end
module ATDIS
end
module ATDIS::Validators
end
class ATDIS::Validators::GeoJsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Validators::DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Validators::HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Validators::ArrayHttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Validators::ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Validators::FilledArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Validators::PresenceBeforeTypeCastValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value); end
end
class ATDIS::Validators::ValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value); end
end
class ATDIS::Feed
  def application(id); end
  def application_url(id); end
  def applications(options = nil); end
  def applications_url(options = nil); end
  def base_url; end
  def initialize(base_url, timezone); end
  def self.base_url_from_url(url); end
  def self.escape(value); end
  def self.options_from_url(url); end
  def self.options_to_query(options); end
  def self.query_to_options(query); end
  def timezone; end
end
class ATDIS::SeparatedURL
  def self.combine(url, url_params); end
  def self.merge(full_url, params); end
  def self.split(full_url); end
end
module ATDIS::TypeCastAttributes
  extend ActiveSupport::Concern
end
module ATDIS::TypeCastAttributes::ClassMethods
  def field_mappings(params); end
end
class ATDIS::ErrorMessage < Struct
  def empty?; end
  def message; end
  def message=(_); end
  def self.[](*arg0); end
  def self.inspect; end
  def self.members; end
  def self.new(*arg0); end
  def spec_section; end
  def spec_section=(_); end
  def to_s; end
end
class ATDIS::Model
  def __callbacks; end
  def __callbacks?; end
  def _run_validate_callbacks(&block); end
  def _validate_callbacks; end
  def _validators; end
  def _validators?; end
  def attribute(attr); end
  def attribute=(attr, value); end
  def attribute_aliases; end
  def attribute_aliases?; end
  def attribute_before_type_cast(attr); end
  def attribute_method_matchers; end
  def attribute_method_matchers?; end
  def attribute_types; end
  def attribute_types=(val); end
  def attribute_types?; end
  def attributes; end
  def attributes_before_type_cast; end
  def initialize(params, timezone); end
  def json_errors; end
  def json_errors_in_children; end
  def json_errors_local; end
  def json_left_overs; end
  def json_left_overs=(arg0); end
  def json_left_overs_is_empty; end
  def json_load_error; end
  def json_load_error=(arg0); end
  def json_loaded_correctly!; end
  def model_name(*args, &block); end
  def self.__callbacks; end
  def self.__callbacks=(val); end
  def self.__callbacks?; end
  def self._validate_callbacks; end
  def self._validate_callbacks=(value); end
  def self._validators; end
  def self._validators=(val); end
  def self._validators?; end
  def self.attribute_aliases; end
  def self.attribute_aliases=(val); end
  def self.attribute_aliases?; end
  def self.attribute_keys; end
  def self.attribute_method_matchers; end
  def self.attribute_method_matchers=(val); end
  def self.attribute_method_matchers?; end
  def self.attribute_names; end
  def self.attribute_types; end
  def self.attribute_types=(val); end
  def self.attribute_types?; end
  def self.cast(value, type, timezone); end
  def self.cast_datetime(value, timezone); end
  def self.cast_geojson(value); end
  def self.cast_integer(value); end
  def self.cast_string(value); end
  def self.cast_uri(value); end
  def self.hash_symbols_to_string(hash); end
  def self.interpret(data, timezone); end
  def self.partition_by_used(data); end
  def self.read_json(text, timezone); end
  def self.read_url(url, timezone); end
  def timezone; end
  def url; end
  def url=(arg0); end
  def used_attribute?(attribute); end
  def validation_context; end
  def validation_context=(arg0); end
  extend ATDIS::TypeCastAttributes::ClassMethods
  extend ActiveModel::AttributeMethods::ClassMethods
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  extend ActiveModel::Validations::ClassMethods
  extend ActiveModel::Validations::HelperMethods
  extend ActiveSupport::Callbacks::ClassMethods
  extend ActiveSupport::DescendantsTracker
  include ATDIS::TypeCastAttributes
  include ATDIS::Validators
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Validations::HelperMethods
  include ActiveSupport::Callbacks
  include Anonymous_Module_52
end
module Anonymous_Module_52
end
module ATDIS::Models
end
class ATDIS::Models::Authority < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_53
end
module Anonymous_Module_53
  def name(*args); end
  def name=(*args); end
  def name_before_type_cast(*args); end
  def ref(*args); end
  def ref=(*args); end
  def ref_before_type_cast(*args); end
end
class ATDIS::Models::Info < ATDIS::Model
  def dat_id_is_url_encoded!; end
  def notification_dates_consistent!; end
  def related_apps_url_format; end
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  def self.url_encoded?(str); end
  include Anonymous_Module_54
end
module Anonymous_Module_54
  def application_type(*args); end
  def application_type=(*args); end
  def application_type_before_type_cast(*args); end
  def authority(*args); end
  def authority=(*args); end
  def authority_before_type_cast(*args); end
  def dat_id(*args); end
  def dat_id=(*args); end
  def dat_id_before_type_cast(*args); end
  def description(*args); end
  def description=(*args); end
  def description_before_type_cast(*args); end
  def determination_date(*args); end
  def determination_date=(*args); end
  def determination_date_before_type_cast(*args); end
  def determination_type(*args); end
  def determination_type=(*args); end
  def determination_type_before_type_cast(*args); end
  def development_type(*args); end
  def development_type=(*args); end
  def development_type_before_type_cast(*args); end
  def estimated_cost(*args); end
  def estimated_cost=(*args); end
  def estimated_cost_before_type_cast(*args); end
  def last_modified_date(*args); end
  def last_modified_date=(*args); end
  def last_modified_date_before_type_cast(*args); end
  def lodgement_date(*args); end
  def lodgement_date=(*args); end
  def lodgement_date_before_type_cast(*args); end
  def notification_end_date(*args); end
  def notification_end_date=(*args); end
  def notification_end_date_before_type_cast(*args); end
  def notification_start_date(*args); end
  def notification_start_date=(*args); end
  def notification_start_date_before_type_cast(*args); end
  def officer(*args); end
  def officer=(*args); end
  def officer_before_type_cast(*args); end
  def related_apps(*args); end
  def related_apps=(*args); end
  def related_apps_before_type_cast(*args); end
  def status(*args); end
  def status=(*args); end
  def status_before_type_cast(*args); end
end
class ATDIS::Models::Reference < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_55
end
module Anonymous_Module_55
  def comments_url(*args); end
  def comments_url=(*args); end
  def comments_url_before_type_cast(*args); end
  def more_info_url(*args); end
  def more_info_url=(*args); end
  def more_info_url_before_type_cast(*args); end
end
class ATDIS::Models::Address < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_56
end
module Anonymous_Module_56
  def postcode(*args); end
  def postcode=(*args); end
  def postcode_before_type_cast(*args); end
  def state(*args); end
  def state=(*args); end
  def state_before_type_cast(*args); end
  def street(*args); end
  def street=(*args); end
  def street_before_type_cast(*args); end
  def suburb(*args); end
  def suburb=(*args); end
  def suburb_before_type_cast(*args); end
end
class ATDIS::Models::TorrensTitle < ATDIS::Model
  def section_can_not_be_empty_string; end
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_57
end
module Anonymous_Module_57
  def dpsp_id(*args); end
  def dpsp_id=(*args); end
  def dpsp_id_before_type_cast(*args); end
  def lot(*args); end
  def lot=(*args); end
  def lot_before_type_cast(*args); end
  def section(*args); end
  def section=(*args); end
  def section_before_type_cast(*args); end
end
class ATDIS::Models::LandTitleRef < ATDIS::Model
  def check_title_presence; end
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_58
end
module Anonymous_Module_58
  def other(*args); end
  def other=(*args); end
  def other_before_type_cast(*args); end
  def torrens(*args); end
  def torrens=(*args); end
  def torrens_before_type_cast(*args); end
end
class ATDIS::Models::Location < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_59
end
module Anonymous_Module_59
  def address(*args); end
  def address=(*args); end
  def address_before_type_cast(*args); end
  def geometry(*args); end
  def geometry=(*args); end
  def geometry_before_type_cast(*args); end
  def land_title_ref(*args); end
  def land_title_ref=(*args); end
  def land_title_ref_before_type_cast(*args); end
end
class ATDIS::Models::Event < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_60
end
module Anonymous_Module_60
  def description(*args); end
  def description=(*args); end
  def description_before_type_cast(*args); end
  def event_type(*args); end
  def event_type=(*args); end
  def event_type_before_type_cast(*args); end
  def id(*args); end
  def id=(*args); end
  def id_before_type_cast(*args); end
  def status(*args); end
  def status=(*args); end
  def status_before_type_cast(*args); end
  def timestamp(*args); end
  def timestamp=(*args); end
  def timestamp_before_type_cast(*args); end
end
class ATDIS::Models::Document < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_61
end
module Anonymous_Module_61
  def document_url(*args); end
  def document_url=(*args); end
  def document_url_before_type_cast(*args); end
  def ref(*args); end
  def ref=(*args); end
  def ref_before_type_cast(*args); end
  def title(*args); end
  def title=(*args); end
  def title_before_type_cast(*args); end
end
class ATDIS::Models::Person < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_62
end
module Anonymous_Module_62
  def contact(*args); end
  def contact=(*args); end
  def contact_before_type_cast(*args); end
  def name(*args); end
  def name=(*args); end
  def name_before_type_cast(*args); end
  def role(*args); end
  def role=(*args); end
  def role_before_type_cast(*args); end
end
class ATDIS::Models::Application < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_63
end
module Anonymous_Module_63
  def documents(*args); end
  def documents=(*args); end
  def documents_before_type_cast(*args); end
  def events(*args); end
  def events=(*args); end
  def events_before_type_cast(*args); end
  def extended(*args); end
  def extended=(*args); end
  def extended_before_type_cast(*args); end
  def info(*args); end
  def info=(*args); end
  def info_before_type_cast(*args); end
  def locations(*args); end
  def locations=(*args); end
  def locations_before_type_cast(*args); end
  def people(*args); end
  def people=(*args); end
  def people_before_type_cast(*args); end
  def reference(*args); end
  def reference=(*args); end
  def reference_before_type_cast(*args); end
end
class ATDIS::Models::Response < ATDIS::Model
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_64
end
module Anonymous_Module_64
  def application(*args); end
  def application=(*args); end
  def application_before_type_cast(*args); end
end
class ATDIS::Models::Pagination < ATDIS::Model
  def all_pagination_is_present; end
  def count_is_consistent; end
  def current_is_consistent; end
  def next_is_consistent; end
  def previous_is_consistent; end
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_65
end
module Anonymous_Module_65
  def count(*args); end
  def count=(*args); end
  def count_before_type_cast(*args); end
  def current(*args); end
  def current=(*args); end
  def current_before_type_cast(*args); end
  def next(*args); end
  def next=(*args); end
  def next_before_type_cast(*args); end
  def pages(*args); end
  def pages=(*args); end
  def pages_before_type_cast(*args); end
  def per_page(*args); end
  def per_page=(*args); end
  def per_page_before_type_cast(*args); end
  def previous(*args); end
  def previous=(*args); end
  def previous_before_type_cast(*args); end
end
class ATDIS::Models::Page < ATDIS::Model
  def all_pagination_is_present; end
  def count_is_consistent; end
  def next_page; end
  def next_url; end
  def previous_page; end
  def previous_url; end
  def self.__callbacks; end
  def self._validators; end
  def self.attribute_types; end
  include Anonymous_Module_66
end
module Anonymous_Module_66
  def count(*args); end
  def count=(*args); end
  def count_before_type_cast(*args); end
  def pagination(*args); end
  def pagination=(*args); end
  def pagination_before_type_cast(*args); end
  def response(*args); end
  def response=(*args); end
  def response_before_type_cast(*args); end
end
