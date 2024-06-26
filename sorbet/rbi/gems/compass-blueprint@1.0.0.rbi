# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `compass-blueprint` gem.
# Please instead update this file by running `bin/tapioca gem compass-blueprint`.

# source://compass-blueprint//lib/compass-blueprint/version.rb#1
module Compass
  private

  # source://compass/1.0.3/lib/compass.rb#20
  def base_directory; end

  # source://compass/1.0.3/lib/compass.rb#23
  def lib_directory; end

  # source://compass-core/1.0.3/lib/compass/core.rb#49
  def shared_extension_paths; end

  class << self
    # source://compass-core/1.0.3/lib/compass/configuration.rb#134
    def add_configuration(data, filename = T.unsafe(nil)); end

    # source://compass/1.0.3/lib/compass.rb#20
    def base_directory; end

    # source://compass-core/1.0.3/lib/compass/configuration.rb#122
    def configuration; end

    def const_missing(const_name); end

    # source://compass-core/1.0.3/lib/compass/configuration.rb#130
    def default_configuration; end

    # source://compass-core/1.0.3/lib/compass/configuration.rb#162
    def deprojectize(path, project_path = T.unsafe(nil)); end

    # source://compass-core/1.0.3/lib/compass/frameworks.rb#169
    def discover_extensions!; end

    # source://compass-core/1.0.3/lib/compass/frameworks.rb#157
    def discover_gem_extensions!; end

    # source://compass/1.0.3/lib/compass.rb#23
    def lib_directory; end

    # source://compass-core/1.0.3/lib/compass/configuration.rb#157
    def projectize(path, project_path = T.unsafe(nil)); end

    # source://compass-core/1.0.3/lib/compass/configuration.rb#152
    def reset_configuration!; end

    # source://compass-core/1.0.3/lib/compass/core.rb#49
    def shared_extension_paths; end
  end
end

# source://compass-blueprint//lib/compass-blueprint/version.rb#2
module Compass::Blueprint; end

# source://compass-blueprint//lib/compass-blueprint/version.rb#3
Compass::Blueprint::VERSION = T.let(T.unsafe(nil), String)

# source://compass/1.0.3/lib/compass/version.rb#36
Compass::VERSION = T.let(T.unsafe(nil), String)

# source://compass/1.0.3/lib/compass/version.rb#40
Compass::VERSION_DETAILS = T.let(T.unsafe(nil), Hash)

# source://compass/1.0.3/lib/compass/version.rb#37
Compass::VERSION_NAME = T.let(T.unsafe(nil), String)
