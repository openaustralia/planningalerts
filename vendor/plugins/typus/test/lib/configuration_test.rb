require "test/helper"

class ConfigurationTest < ActiveSupport::TestCase

  def test_should_verify_configuration_responds_to_options
    assert Typus::Configuration.respond_to?(:options)
  end

  def test_should_verify_application_wide_configuration_options
    initializer = "#{Rails.root}/config/initializers/typus.rb"
    return if File.exist?(initializer)
    assert_equal "Typus", Typus::Configuration.options[:app_name]
    assert_equal "vendor/plugins/typus/test/config/working", Typus::Configuration.options[:config_folder]
    assert_equal "columbia", Typus::Configuration.options[:default_password]
    assert_equal nil, Typus::Configuration.options[:email]
    assert_equal :typus_preview, Typus::Configuration.options[:file_preview]
    assert_equal :typus_thumbnail, Typus::Configuration.options[:file_thumbnail]
    assert_equal "typus_users", Typus::Configuration.options[:relationship]
    assert_equal "admin", Typus::Configuration.options[:root]
    assert_equal "TypusUser", Typus::Configuration.options[:user_class_name]
    assert_equal "typus_user_id", Typus::Configuration.options[:user_fk]
  end

  def test_should_verify_model_configuration_options
    initializer = "#{Rails.root}/config/initializers/typus.rb"
    return if File.exist?(initializer)
    assert_equal "edit", Typus::Configuration.options[:default_action_on_item]
    assert_nil Typus::Configuration.options[:end_year]
    assert_equal 15, Typus::Configuration.options[:form_rows]
    assert_equal false, Typus::Configuration.options[:index_after_save]
    assert_equal 5, Typus::Configuration.options[:minute_step]
    assert_equal "nil", Typus::Configuration.options[:nil]
    assert_equal false, Typus::Configuration.options[:on_header]
    assert_equal false, Typus::Configuration.options[:only_user_items]
    assert_equal 15, Typus::Configuration.options[:per_page]
    assert_equal 5, Typus::Configuration.options[:sidebar_selector]
    assert_nil Typus::Configuration.options[:start_year]
  end

  def test_should_verify_typus_roles_is_loaded
    assert Typus::Configuration.respond_to?(:roles!)
    assert Typus::Configuration.roles!.kind_of?(Hash)
  end

  def test_should_verify_typus_config_file_is_loaded
    assert Typus::Configuration.respond_to?(:config!)
    assert Typus::Configuration.config!.kind_of?(Hash)
  end

  def test_should_load_configuration_files_from_config_broken
    options = { :config_folder => "vendor/plugins/typus/test/config/broken" }
    Typus::Configuration.stubs(:options).returns(options)
    assert_not_equal Hash.new, Typus::Configuration.roles!
    assert_not_equal Hash.new, Typus::Configuration.config!
  end

  def test_should_load_configuration_files_from_config_empty
    options = { :config_folder => "vendor/plugins/typus/test/config/empty" }
    Typus::Configuration.stubs(:options).returns(options)
    assert_equal Hash.new, Typus::Configuration.roles!
    assert_equal Hash.new, Typus::Configuration.config!
  end

  def test_should_load_configuration_files_from_config_ordered
    options = { :config_folder => "vendor/plugins/typus/test/config/ordered" }
    Typus::Configuration.stubs(:options).returns(options)
    files = Dir["#{Rails.root}/#{Typus::Configuration.options[:config_folder]}/*_roles.yml"]
    expected = files.collect { |file| File.basename(file) }.sort
    assert_equal expected, ["001_roles.yml", "002_roles.yml"]
    expected = { "admin" => { "categories" => "read" } }
    assert_equal expected, Typus::Configuration.roles!
  end

  def test_should_load_configuration_files_from_config_unordered
    options = { :config_folder => "vendor/plugins/typus/test/config/unordered" }
    Typus::Configuration.stubs(:options).returns(options)
    files = Dir["#{Rails.root}/#{Typus::Configuration.options[:config_folder]}/*_roles.yml"]
    expected = files.collect { |file| File.basename(file) }
    assert_equal expected, ["app_one_roles.yml", "app_two_roles.yml"]
    expected = { "admin" => { "categories" => "read, update" } }
    assert_equal expected, Typus::Configuration.roles!
  end

  def test_should_load_configuration_files_from_config_default
    options = { :config_folder => "vendor/plugins/typus/test/config/default" }
    Typus::Configuration.stubs(:options).returns(options)
    assert_not_equal Hash.new, Typus::Configuration.roles!
    assert_not_equal Hash.new, Typus::Configuration.config!
    assert Typus.resources.empty?
  end

end