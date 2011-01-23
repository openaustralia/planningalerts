ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do

  create_table :assets, :force => true do |t|
    t.string :caption
    t.string :resource_type
    t.integer :resource_id
    t.integer :position
  end

  create_table :categories, :force => true do |t|
    t.string :name
    t.string :permalink
    t.text :description
    t.integer :position
  end

  create_table :comments, :force => true do |t|
    t.string :email, :name
    t.text :body
    t.integer :post_id
  end

  add_index :comments, :post_id

  create_table :delayed_tasks, :force => true do |t|
    t.string :name
  end

  create_table :pages, :force => true do |t|
    t.string :title
    t.text :body
    t.boolean :is_published
    t.integer :parent_id
  end

  create_table :posts, :force => true do |t|
    t.string :title
    t.text :body
    t.string :status
    t.integer :favorite_comment_id
    t.timestamps
    t.datetime :published_at
    t.integer :typus_user_id
  end
  
  create_table :pictures, :force => true do |t|
    t.string :title
    t.string :picture_file_name
    t.string :picture_content_type
    t.integer :picture_file_size
    t.datetime :picture_updated_at
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :typus_user_id
  end

  create_table :typus_users, :force => true do |t|
    t.string :first_name, :default => "", :null => false
    t.string :last_name, :default => "", :null => false
    t.string :role, :null => false
    t.string :email, :null => false
    t.boolean :status, :default => false
    t.string :token, :null => false
    t.string :salt, :null => false
    t.string :crypted_password, :null => false
    t.string :preferences
    t.timestamps
  end

  create_table :views, :force => true do |t|
    t.string :ip, :default => '127.0.0.1'
    t.integer :post_id
    t.timestamps
  end

  create_table :categories_posts, :force => true, :id => false do |t|
    t.column :category_id, :integer
    t.column :post_id, :integer
  end

  add_index :categories_posts, :category_id
  add_index :categories_posts, :post_id

end
