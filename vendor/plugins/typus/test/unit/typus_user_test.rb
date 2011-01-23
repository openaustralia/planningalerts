require 'test/helper'

class TypusUserTest < ActiveSupport::TestCase

  def setup
    @data = { :first_name => '', 
              :last_name => '', 
              :email => 'test@example.com', 
              :password => '12345678', 
              :password_confirmation => '12345678', 
              :role => Typus::Configuration.options[:root], 
              :preferences => { :locale => :en } }
    @typus_user = TypusUser.new(@data)
  end

  def test_should_verify_typus_user_attributes
    [ :first_name, :last_name, :email, :role, :salt, :crypted_password ].each do |attribute|
      assert TypusUser.instance_methods.map { |i| i.to_sym }.include?(attribute)
    end
  end

  def test_should_verify_definition_on_instance_methods
    [ :is_root?, :authenticated? ].each do |instance_method|
      assert TypusUser.instance_methods.map { |i| i.to_sym }.include?(instance_method)
    end
  end

  def test_should_verify_email_format
    @typus_user.email = 'admin'
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:email)
  end

  def test_should_verify_email_is_not_valid
    email = <<-RAW
this_is_chelm@example.com
<script>location.href="http://spammersite.com"</script>
    RAW
    @typus_user.email = email
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:email)
  end

  def test_should_verify_emails_are_downcase
    email = 'TEST@EXAMPLE.COM'
    @typus_user.email = email
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:email)
  end

  def test_should_verify_some_valid_emails_schemas
    emails = [ 'test+filter@example.com', 
               'test.filter@example.com', 
               'test@example.co.uk', 
               'test@example.es' ]
    emails.each do |email|
      @typus_user.email = email
      assert @typus_user.valid?
    end
  end

  def test_should_verify_invalid_emails_are_detected
    emails = [ 'test@example', 'test@example.c', 'testexample.com' ]
    emails.each do |email|
      @typus_user.email = email
      assert @typus_user.invalid?
      assert @typus_user.errors.invalid?(:email)
    end
  end

  def test_should_verify_email_is_unique
    @typus_user.save
    @another_typus_user = TypusUser.new(@data)
    assert @another_typus_user.invalid?
    assert @another_typus_user.errors.invalid?(:email)
  end

  def test_should_verify_length_of_password_when_under_within
    @typus_user.password = '1234'
    @typus_user.password_confirmation = '1234'
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:password)
  end

  def test_should_verify_length_of_password_when_its_within_on_lower_limit
    @typus_user.password = '=' * 8
    @typus_user.password_confirmation = '=' * 8
    assert @typus_user.valid?
  end

  def test_should_verify_length_of_password_when_its_within_on_upper_limit
    @typus_user.password = '=' * 40
    @typus_user.password_confirmation = '=' * 40
    assert @typus_user.valid?
  end

  def test_should_verify_length_of_password_when_its_over_within
    @typus_user.password = '=' * 50
    @typus_user.password_confirmation = '=' * 50
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:password)
  end

  def test_should_verify_confirmation_of_password

    @typus_user.password = '12345678'
    @typus_user.password_confirmation = '87654321'
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:password)

    @typus_user.password = '12345678'
    @typus_user.password_confirmation = ''
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:password)

  end

  def test_should_verify_role
    @typus_user.role = ''
    assert @typus_user.invalid?
    assert @typus_user.errors.invalid?(:role)
    assert_equal "can't be blank", @typus_user.errors[:role]
  end

  def test_should_return_name_when_only_email
    assert_equal @typus_user.email, @typus_user.name
  end

  def test_should_return_name_when_theres_first_name_and_last_name
    @typus_user.first_name = 'John'
    @typus_user.last_name = 'Smith'
    assert_equal 'John Smith', @typus_user.name
  end

  def test_should_return_verify_is_root
    assert @typus_user.is_root?
    editor = typus_users(:editor)
    assert editor.is_not_root?
  end

  def test_should_verify_authenticated
    @typus_user.save
    assert @typus_user.authenticated?('12345678')
    assert !@typus_user.authenticated?('87654321')
  end

  def test_should_verify_typus_user_can_be_created
    assert_difference 'TypusUser.count' do
      TypusUser.create(@data)
    end
  end

  def test_should_verify_salt_on_user_never_changes

    @typus_user.save
    salt = @typus_user.salt
    crypted_password = @typus_user.crypted_password

    @typus_user.update_attributes :password => '11111111', :password_confirmation => '11111111'
    assert_equal salt, @typus_user.salt
    assert_not_equal crypted_password, @typus_user.crypted_password

  end

  def test_should_verify_generate
    assert TypusUser.respond_to?(:generate)
    assert TypusUser.generate(:email => 'demo@example.com', :password => 'XXXXXXXX').invalid?
    assert TypusUser.generate(:email => 'demo@example.com', :password => 'XXXXXXXX', :role => 'admin').valid?
  end

  def test_should_verify_can?
    assert TypusUser.instance_methods.map { |i| i.to_sym }.include?(:can?)
    @current_user = TypusUser.find(:first)
    assert @current_user.can?('delete', TypusUser)
    assert @current_user.can?('delete', 'TypusUser')
    assert !@current_user.cannot?('delete', 'TypusUser')
  end

end