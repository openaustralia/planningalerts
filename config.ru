require "config/environment"

use Rails::Rack::LogTailer
use Rails::Rack::Static
# This makes sure that cached pages (that end in .php) get served as html rather than plain text
Rack::Mime::MIME_TYPES[".php"] = "text/html"
run ActionController::Dispatcher.new
