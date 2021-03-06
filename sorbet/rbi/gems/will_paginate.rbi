# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: true
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/will_paginate/all/will_paginate.rbi
#
# will_paginate-3.3.0

module WillPaginate
  def self.PageNumber(value, name = nil); end
  extend WillPaginate::PerPage
end
module WillPaginate::InvalidPage
end
class WillPaginate::PageNumber < Numeric
  def *(*args, &block); end
  def +(*args, &block); end
  def -(*args, &block); end
  def /(*args, &block); end
  def <=>(*args, &block); end
  def ==(*args, &block); end
  def coerce(*args, &block); end
  def initialize(value, name); end
  def inspect; end
  def is_a?(klass); end
  def kind_of?(klass); end
  def to_i; end
  def to_json(*args, &block); end
  def to_offset(per_page); end
  def to_s(*args, &block); end
  extend Forwardable
end
module WillPaginate::PerPage
  def per_page; end
  def per_page=(limit); end
  def self.extended(base); end
end
module WillPaginate::PerPage::Inheritance
  def inherited(subclass); end
end
module WillPaginate::CollectionMethods
  def next_page; end
  def out_of_bounds?; end
  def previous_page; end
  def total_pages; end
end
class WillPaginate::Collection < Array
  def current_page; end
  def initialize(page, per_page = nil, total = nil); end
  def offset; end
  def per_page; end
  def replace(array); end
  def self.create(page, per_page, total = nil); end
  def total_entries; end
  def total_entries=(number); end
  include WillPaginate::CollectionMethods
end
module WillPaginate::I18n
  def self.load_path; end
  def self.locale_dir; end
  def will_paginate_translate(keys, options = nil, &block); end
end
class WillPaginate::Railtie < Rails::Railtie
  def self.setup_actioncontroller; end
end
module WillPaginate::Railtie::ShowExceptionsPatch
  def status_code_with_paginate(exception = nil); end
  extend ActiveSupport::Concern
end
module WillPaginate::Railtie::ControllerRescuePatch
  def rescue_from(*args, **kwargs, &block); end
end
module WillPaginate::ActiveRecord
end
module WillPaginate::ActiveRecord::RelationMethods
  def clone; end
  def copy_will_paginate_data(other); end
  def count(*args); end
  def current_page; end
  def current_page=(arg0); end
  def empty?; end
  def find_last(*args); end
  def first(*args); end
  def limit(num); end
  def offset(value = nil); end
  def per_page(value = nil); end
  def scoped(options = nil); end
  def size; end
  def to_a; end
  def total_entries; end
  def total_entries=(arg0); end
  include WillPaginate::CollectionMethods
end
module WillPaginate::ActiveRecord::Pagination
  def page(num); end
  def paginate(options); end
end
module WillPaginate::ActiveRecord::BaseMethods
  def paginate_by_sql(sql, options); end
end
class ActiveRecord::Base
  extend WillPaginate::ActiveRecord::BaseMethods
  extend WillPaginate::ActiveRecord::Pagination
  extend WillPaginate::PerPage
  extend WillPaginate::PerPage::Inheritance
end
class ActiveRecord::Relation
  include WillPaginate::ActiveRecord::Pagination
end
class ActiveRecord::Associations::CollectionProxy < ActiveRecord::Relation
  include WillPaginate::ActiveRecord::Pagination
end
module WillPaginate::Deprecation
  def self.origin_of_call(stack); end
  def self.rails_logger; end
  def self.warn(message, stack = nil); end
end
class WillPaginate::Deprecation::Hash < Hash
  def []=(key, value); end
  def check_deprecated(key, value); end
  def deprecate_key(*keys, &block); end
  def initialize(values = nil); end
  def merge(another); end
  def to_hash; end
end
module WillPaginate::ViewHelpers
  def page_entries_info(collection, options = nil); end
  def self.pagination_options; end
  def self.pagination_options=(arg0); end
  def will_paginate(collection, options = nil); end
  include WillPaginate::I18n
end
class WillPaginate::ViewHelpers::LinkRendererBase
  def current_page; end
  def pagination; end
  def prepare(collection, options); end
  def total_pages; end
  def windowed_page_numbers; end
end
class WillPaginate::ViewHelpers::LinkRenderer < WillPaginate::ViewHelpers::LinkRendererBase
  def container_attributes; end
  def gap; end
  def html_container(html); end
  def link(text, target, attributes = nil); end
  def next_page; end
  def page_number(page); end
  def param_name; end
  def prepare(collection, options, template); end
  def previous_or_next_page(page, text, classname); end
  def previous_page; end
  def rel_value(page); end
  def symbolized_update(target, other, blacklist = nil); end
  def tag(name, value, attributes = nil); end
  def to_html; end
  def url(page); end
end
module WillPaginate::ActionView
  def infer_collection_from_controller; end
  def page_entries_info(collection = nil, options = nil); end
  def paginated_section(*args, &block); end
  def will_paginate(collection = nil, options = nil); end
  def will_paginate_translate(keys, options = nil); end
  include WillPaginate::ViewHelpers
end
class WillPaginate::ActionView::LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def add_current_page_param(url_params, page); end
  def default_url_params; end
  def merge_get_params(url_params); end
  def merge_optional_params(url_params); end
  def parse_query_parameters(params); end
  def url(page); end
end
class ActionView::Base
  include WillPaginate::ActionView
end
class Array
  def paginate(options = nil); end
end
