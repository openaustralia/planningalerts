require "open-uri"

ActiveAdmin.register Authority do
  actions :all, except: [:destroy]

  scope :active, default: true
  scope(:disabled) { |a| a.where(disabled: true) }
  scope :all

  index do
    column "Name", :full_name
    column :state
    column :email
    column(:number_of_applications) { |a| a.applications.count }
    column(:number_of_comments) { |a| a.comments.count }
    column :write_to_councillors_enabled
    column(:number_of_councillors) { |a| a.councillors.count }
    actions
  end

  show title: :full_name do |a|
    attributes_table do
      row :full_name
      row :short_name
      row :lga_name15
      row :state
      row :email
      row :write_to_councillors_enabled
      row :population_2011
      row :superceded_by
      row :morph_name
      row :disabled
    end

    h3 "Councillors"
    if a.councillors.present?
      table_for resource.councillors, class: "index_table" do
        column :name
        column :email
        column :party
        column(:image) { |c| link_to image_tag(c.image_url), c.image_url }
        # TODO: Add delete action
        column { |c| "#{link_to "View", admin_councillor_path(c)} #{link_to "Edit", edit_admin_councillor_path(c)}".html_safe }
      end
    else
      para "None loaded for this authority."
    end

    h3 "Last scraper run log"
    div do
      simple_format a.last_scraper_run_log
    end
  end

  filter :full_name

  form do |f|
    inputs "Name" do
      input :full_name
      input :short_name
    end
    inputs "Details" do
      input :state
      input :email
      input :lga_name15, hint: "What is the ABS name for this authority?"
      input :population_2011
      input :write_to_councillors_enabled
    end
    inputs "Scraping" do
      input :superceded_by, hint: 'The short name of another authority that replaces this one', placeholder: 'spear'
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

  action_item :load_councillors, only: :show do
    button_to('Load Councillors', load_councillors_admin_authority_path)
  end

  member_action :load_councillors, method: :post do
    popolo = EveryPolitician::Popolo.parse(open(resource.popolo_url).read)
    results = resource.load_councillors(popolo)
    notice = render_to_string(partial: "load_councillors_message", locals: {councillors: results})

    redirect_to({action: :show}, notice: notice)
  end

  csv do
    column :full_name
    column :short_name
    column :lga_name15
    column :disabled
    column :write_to_councillors_enabled
    column :state
    column :email
    column :population_2011
    column :superceded_by
    column :morph_name
    column(:number_of_applications) { |a| a.applications.count }
    column(:number_of_comments) { |a| a.comments.count }
  end

  permit_params :full_name, :short_name, :state, :email, :write_to_councillors_enabled, :population_2011, :morph_name, :disabled, :superceded_by, :lga_name15
end
