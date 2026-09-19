# typed: false
# frozen_string_literal: true

# IdleBasicAuth lives in app/middleware and is autoloaded by the "once"
# autoloader (see config.autoload_once_paths in config/application.rb), which
# is set up before config/initializers runs. Registering it here rather than in
# config/application.rb keeps the middleware class out of that file, and works
# because the middleware stack is not built until after the initializers have
# all run.
#
# Position 0 is deliberate: it has to sit in front of ActionDispatch::Static.
# See the comment on the class.
Rails.application.config.middleware.insert_before 0, IdleBasicAuth
