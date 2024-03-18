class AddPostgisExtensionToDatabase < ActiveRecord::Migration[7.0]
  def change
    enable_extension "postgis" unless extension_enabled?("postgis")
  end
end
