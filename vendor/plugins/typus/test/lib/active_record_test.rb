require "test/helper"

class ActiveRecordTest < ActiveSupport::TestCase

  def test_should_verify_model_fields_is_an_instance_of_active_support_ordered_hash
    assert TypusUser.model_fields.instance_of?(ActiveSupport::OrderedHash)
  end

  def test_should_return_model_fields_for_typus_user
    expected_fields = [[:id, :integer], 
                       [:first_name, :string], 
                       [:last_name, :string], 
                       [:role, :string], 
                       [:email, :string], 
                       [:status, :boolean], 
                       [:token, :string], 
                       [:salt, :string], 
                       [:crypted_password, :string], 
                       [:preferences, :string], 
                       [:created_at, :datetime], 
                       [:updated_at, :datetime]]
    assert_equal expected_fields.map { |i| i.first }, TypusUser.model_fields.keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.model_fields.values
  end

  def test_should_return_model_fields_for_post
    expected_fields = [[:id, :integer],
                       [:title, :string],
                       [:body, :text],
                       [:status, :string],
                       [:favorite_comment_id, :integer],
                       [:created_at, :datetime],
                       [:updated_at, :datetime],
                       [:published_at, :datetime], 
                       [:typus_user_id, :integer]]
    assert_equal expected_fields.map { |i| i.first }, Post.model_fields.keys
    assert_equal expected_fields.map { |i| i.last }, Post.model_fields.values
  end

  def test_should_verify_model_relationships_is_an_instance_of_active_support_ordered_hash
    assert TypusUser.model_relationships.instance_of?(ActiveSupport::OrderedHash)
  end

  def test_should_return_model_relationships_for_post
    expected = [[:comments, :has_many],
                [:categories, :has_and_belongs_to_many],
                [:user, nil],
                [:assets, :has_many]]
    expected.each do |i|
      assert_equal i.last, Post.model_relationships[i.first]
    end
  end

  def test_should_return_description_of_a_model
    assert TypusUser.respond_to?(:typus_description)
    assert_equal "System Users Administration", TypusUser.typus_description
  end

  def test_should_return_typus_fields_for_list_for_typus_user
    expected_fields = [["email", :string], 
                       ["role", :selector], 
                       ["status", :boolean]]
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for("list").keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for("list").values
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for(:list).keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for(:list).values
  end

  def test_should_return_typus_fields_for_list_for_post
    expected_fields = [["title", :string],
                       ["created_at", :datetime],
                       ["status", :selector]]
    assert_equal expected_fields.map { |i| i.first }, Post.typus_fields_for("list").keys
    assert_equal expected_fields.map { |i| i.last }, Post.typus_fields_for("list").values
    assert_equal expected_fields.map { |i| i.first }, Post.typus_fields_for(:list).keys
    assert_equal expected_fields.map { |i| i.last }, Post.typus_fields_for(:list).values
  end

  def test_should_return_typus_fields_for_form_for_typus_user
    expected_fields = [["first_name", :string], 
                       ["last_name", :string], 
                       ["role", :selector], 
                       ["email", :string], 
                       ["password", :password], 
                       ["password_confirmation", :password]]
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for("form").keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for("form").values
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for(:form).keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for(:form).values
  end

  def test_should_return_typus_fields_for_form_for_picture
    expected_fields = [["title", :string], 
                       ["picture", :file]]
    assert_equal expected_fields.map { |i| i.first }, Picture.typus_fields_for("form").keys
    assert_equal expected_fields.map { |i| i.last }, Picture.typus_fields_for("form").values
    assert_equal expected_fields.map { |i| i.first }, Picture.typus_fields_for(:form).keys
    assert_equal expected_fields.map { |i| i.last }, Picture.typus_fields_for(:form).values
  end

  def test_should_return_typus_fields_for_a_model_without_configuration
    expected_fields = []
    klass = Class.new(ActiveRecord::Base)
    assert_equal expected_fields, klass.typus_fields_for(:form)
    assert_equal expected_fields, klass.typus_fields_for(:list)
  end

  def test_should_return_typus_fields_for_relationship_for_typus_user
    expected_fields = [["email", :string], 
                       ["role", :selector], 
                       ["status", :boolean]]
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for("relationship").keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for("relationship").values
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for(:relationship).keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for(:relationship).values
  end

  def test_should_return_all_fields_for_undefined_field_type_on_typus_user
    expected_fields = [["email", :string], 
                       ["role", :selector], 
                       ["status", :boolean]]
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for("undefined").keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for("undefined").values
    assert_equal expected_fields.map { |i| i.first }, TypusUser.typus_fields_for(:undefined).keys
    assert_equal expected_fields.map { |i| i.last }, TypusUser.typus_fields_for(:undefined).values
  end

  def test_should_return_filters_for_typus_user
    expected = [["status", :boolean], 
                ["role", :string]]
    assert_equal "status, role", Typus::Configuration.config["TypusUser"]["filters"]
    assert_equal expected.map { |i| i.first }, TypusUser.typus_filters.keys
    assert_equal expected.map { |i| i.last }, TypusUser.typus_filters.values
  end

  def test_should_return_post_typus_filters
    expected = [["status", :string], 
                ["created_at", :datetime], 
                ["user", nil], 
                ["user_id", nil]]
    assert_equal expected.map { |i| i.first }.join(", "), Typus::Configuration.config["Post"]["filters"]
    assert_equal expected.map { |i| i.first }, Post.typus_filters.keys
    assert_equal expected.map { |i| i.last }, Post.typus_filters.values
  end

  def test_should_return_actions_on_list_for_typus_user
    assert TypusUser.typus_actions_on("list").empty?
    assert TypusUser.typus_actions_on(:list).empty?
  end

  def test_should_return_post_actions_on_index
    assert_equal %w( cleanup ), Post.typus_actions_on("index")
    assert_equal %w( cleanup ), Post.typus_actions_on(:index)
  end

  def test_should_return_post_actions_on_edit
    assert_equal %w( send_as_newsletter preview ), Post.typus_actions_on("edit")
    assert_equal %w( send_as_newsletter preview ), Post.typus_actions_on(:edit)
  end

  def test_should_return_post_actions
    assert_equal %w( cleanup preview send_as_newsletter ), Post.typus_actions.sort
  end

  def test_should_return_field_options_for_post
    assert_equal [ :status ], Post.typus_field_options_for("selectors")
    assert_equal [ :status ], Post.typus_field_options_for(:selectors)
    assert_equal [ :permalink ], Post.typus_field_options_for("read_only")
    assert_equal [ :permalink ], Post.typus_field_options_for(:read_only)
    assert_equal [ :created_at ], Post.typus_field_options_for("auto_generated")
    assert_equal [ :created_at ], Post.typus_field_options_for(:auto_generated)
  end

  def test_should_return_options_for_post_and_page

    assert_equal 15, Post.typus_options_for(:form_rows)
    assert_equal 15, Post.typus_options_for("form_rows")

    assert_equal 25, Page.typus_options_for(:form_rows)
    assert_equal 25, Page.typus_options_for("form_rows")

    assert_equal 15, Asset.typus_options_for(:form_rows)
    assert_equal 15, Asset.typus_options_for("form_rows")

    assert_equal 15, TypusUser.typus_options_for(:form_rows)
    assert_equal 15, TypusUser.typus_options_for("form_rows")

    assert Page.typus_options_for(:on_header)
    assert !TypusUser.typus_options_for(:on_header)

    assert_nil TypusUser.typus_options_for(:unexisting)

  end

  def test_should_verify_typus_boolean_is_an_instance_of_active_support_ordered_hash
    assert TypusUser.typus_boolean("status").instance_of?(ActiveSupport::OrderedHash)
  end

  def test_should_return_booleans_for_typus_users
    assert_equal [ :true, :false ], TypusUser.typus_boolean("status").keys
    assert_equal [ "Active", "Inactive" ], TypusUser.typus_boolean("status").values
    assert_equal [ :true, :false ], TypusUser.typus_boolean(:status).keys
    assert_equal [ "Active", "Inactive" ], TypusUser.typus_boolean(:status).values
  end

  def test_should_return_booleans_for_post
    assert_equal [ :true, :false ], Post.typus_boolean("status").keys
    assert_equal [ "True", "False" ], Post.typus_boolean("status").values
    assert_equal [ :true, :false ], Post.typus_boolean(:status).keys
    assert_equal [ "True", "False" ], Post.typus_boolean(:status).values
  end

  def test_should_return_date_formats_for_post
    assert_equal :post_short, Post.typus_date_format("created_at")
    assert_equal :post_short, Post.typus_date_format(:created_at)
    assert_equal :db, Post.typus_date_format
    assert_equal :db, Post.typus_date_format("unknown")
    assert_equal :db, Post.typus_date_format(:unknown)
  end

  def test_should_return_defaults_for_post
    assert_equal %w( title ), Post.typus_defaults_for("search")
    assert_equal %w( title ), Post.typus_defaults_for(:search)
    assert_equal %w( title -created_at ), Post.typus_defaults_for("order_by")
    assert_equal %w( title -created_at ), Post.typus_defaults_for(:order_by)
  end

  def test_should_return_relationships_for_post
    assert_equal %w( assets categories comments views ), Post.typus_defaults_for("relationships")
    assert_equal %w( assets categories comments views ), Post.typus_defaults_for(:relationships)
    assert !Post.typus_defaults_for("relationships").empty?
    assert !Post.typus_defaults_for(:relationships).empty?
  end

  def test_should_return_order_by_for_model
    assert_equal "posts.title ASC, posts.created_at DESC", Post.typus_order_by
    assert_equal %w( title -created_at ), Post.typus_defaults_for("order_by")
    assert_equal %w( title -created_at ), Post.typus_defaults_for(:order_by)
  end

  def test_should_return_sql_conditions_on_search_for_typus_user
    expected = "(first_name LIKE '%francesc%' OR last_name LIKE '%francesc%' OR email LIKE '%francesc%' OR role LIKE '%francesc%')"
    params = { :search => "francesc" }
    assert_equal expected, TypusUser.build_conditions(params).first
    params = { :search => "Francesc" }
    assert_equal expected, TypusUser.build_conditions(params).first
  end

  def test_should_return_sql_conditions_on_search_and_filter_for_typus_user

    case ENV["DB"]
    when /mysql/
      boolean_true = "(`typus_users`.`status` = 1)"
      boolean_false = "(`typus_users`.`status` = 0)"
    else
      boolean_true = "(\"typus_users\".\"status\" = 't')"
      boolean_false = "(\"typus_users\".\"status\" = 'f')"
    end

    expected = "((first_name LIKE '%francesc%' OR last_name LIKE '%francesc%' OR email LIKE '%francesc%' OR role LIKE '%francesc%')) AND #{boolean_true}"
    params = { :search => "francesc", :status => "true" }
    assert_equal expected, TypusUser.build_conditions(params).first
    params = { :search => "francesc", :status => "false" }
    assert_match /#{boolean_false}/, TypusUser.build_conditions(params).first

  end

  def test_should_return_sql_conditions_on_filtering_typus_users_by_status

    case ENV["DB"]
    when /mysql/
      boolean_true = "(`typus_users`.`status` = 1)"
      boolean_false = "(`typus_users`.`status` = 0)"
    else
      boolean_true = "(\"typus_users\".\"status\" = 't')"
      boolean_false = "(\"typus_users\".\"status\" = 'f')"
    end

    params = { :status => "true" }
    assert_equal boolean_true, TypusUser.build_conditions(params).first
    params = { :status => "false" }
    assert_equal boolean_false, TypusUser.build_conditions(params).first

  end

  def test_should_return_sql_conditions_on_filtering_typus_users_by_created_at

    expected = case ENV["DB"]
               when /postgresql/
                 "(created_at BETWEEN E'#{Time.new.midnight.to_s(:db)}' AND E'#{Time.new.midnight.tomorrow.to_s(:db)}')"
               else
                 "(created_at BETWEEN '#{Time.new.midnight.to_s(:db)}' AND '#{Time.new.midnight.tomorrow.to_s(:db)}')"
               end
    params = { :created_at => "today" }
    assert_equal expected, TypusUser.build_conditions(params).first

    expected = case ENV["DB"]
               when /postgresql/
                 "(created_at BETWEEN E'#{3.days.ago.midnight.to_s(:db)}' AND E'#{Time.new.midnight.tomorrow.to_s(:db)}')"
               else
                 "(created_at BETWEEN '#{3.days.ago.midnight.to_s(:db)}' AND '#{Time.new.midnight.tomorrow.to_s(:db)}')"
               end
    params = { :created_at => "last_few_days" }
    assert_equal expected, TypusUser.build_conditions(params).first

    expected = case ENV["DB"]
               when /postgresql/
                 "(created_at BETWEEN E'#{6.days.ago.midnight.to_s(:db)}' AND E'#{Time.new.midnight.tomorrow.to_s(:db)}')"
               else
                 "(created_at BETWEEN '#{6.days.ago.midnight.to_s(:db)}' AND '#{Time.new.midnight.tomorrow.to_s(:db)}')"
               end
    params = { :created_at => "last_7_days" }
    assert_equal expected, TypusUser.build_conditions(params).first


    expected = case ENV["DB"]
               when /postgresql/
                 "(created_at BETWEEN E'#{Time.new.midnight.last_month.to_s(:db)}' AND E'#{Time.new.midnight.tomorrow.to_s(:db)}')"
               else
                 "(created_at BETWEEN '#{Time.new.midnight.last_month.to_s(:db)}' AND '#{Time.new.midnight.tomorrow.to_s(:db)}')"
               end
    params = { :created_at => "last_30_days" }
    assert_equal expected, TypusUser.build_conditions(params).first

  end

  def test_should_return_sql_conditions_on_filtering_posts_by_published_at
    expected = case ENV["DB"]
               when /postgresql/
                 "(published_at BETWEEN E'#{Time.new.midnight.to_s(:db)}' AND E'#{Time.new.midnight.tomorrow.to_s(:db)}')"
               else
                 "(published_at BETWEEN '#{Time.new.midnight.to_s(:db)}' AND '#{Time.new.midnight.tomorrow.to_s(:db)}')"
               end
    params = { :published_at => "today" }
    assert_equal expected, Post.build_conditions(params).first
  end

  def test_should_return_sql_conditions_on_filtering_posts_by_string
    expected = case ENV["DB"]
               when /postgresql/
                 "(\"typus_users\".\"role\" = E'admin')"
               when /mysql/
                 "(`typus_users`.`role` = 'admin')"
               else
                 "(\"typus_users\".\"role\" = 'admin')"
               end
    params = { :role => "admin" }
    assert_equal expected, TypusUser.build_conditions(params).first
  end

  def test_should_verify_typus_user_id
    assert Post.typus_user_id?
    assert !TypusUser.typus_user_id?
  end

end
