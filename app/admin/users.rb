ActiveAdmin.register User do
  actions :index, :show

  index :download_links => false do
    column :email
    column :name
    column :organisation
    column :api_key
    column "Total API calls" do |u|
      u.api_statistics.count
    end
    column "API calls in last month" do |u|
      u.api_statistics.where("query_time >= ?", 1.month.ago).count
    end
    column :bulk_api
    column :admin
    default_actions
  end
end
