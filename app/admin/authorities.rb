ActiveAdmin.register Authority do
  actions :all, except: [:destroy]

  scope :active, default: true
  scope :all

  index do
    column "Name", :full_name
    column :state
    column :email
    actions
  end

  show title: :full_name do |a|
    attributes_table do
      row :full_name
      row :short_name
      row :state
      row :email
      row :population_2011
      row :morph_name
      row :disabled
    end

    h3 "Last scraper run log"
    div do
      simple_format a.last_scraper_run_log
    end
  end

  remove_filter :applications

  form do |f|
    inputs "Name" do
      input :full_name
      input :short_name
    end
    inputs "Details" do
      input :state
      input :email
      input :population_2011
    end
    inputs "Scraping" do
      input :morph_name, hint: "The name of the scraper at morph.io", placeholder: "planningalerts-scrapers/scraper-blue-mountains"
      input :disabled
    end
    actions
  end

  action_item :scrape, only: :show do
    button_to('Scrape', scrape_admin_authority_path)
  end

  member_action :scrape, method: :post do
    authority = Authority.find(params[:id])
    authority.delay.collect_applications
    redirect_to({action: :show}, notice: "Queued for scraping!")
  end

  permit_params :full_name, :short_name, :state, :email, :population_2011, :morph_name, :disabled
end
