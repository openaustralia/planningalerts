class AddCouncilWebsiteUrlToAuthoritie < ActiveRecord::Migration
  def change
    add_column :authorities, :council_website, :string
  end
end
