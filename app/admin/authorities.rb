ActiveAdmin.register Authority do
  actions :all, :except => [:destroy]

  scope :active, :default => true
  scope :all

  index do
    column "Name", :full_name
    column :state
    default_actions
  end

  action_item :only => :show do
    button_to('Scrape', scrape_admin_authority_path)
  end

  member_action :scrape, :method => :post do
    authority = Authority.find(params[:id])
    authority.delay.collect_applications
    redirect_to({:action => :show}, :notice => "Queued for scraping!")
  end
end
