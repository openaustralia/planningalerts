# typed: false
# frozen_string_literal: true

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
    column(:applications) { |a| a.applications.count }
    column(:total_comments) { |a| a.comments.count }
    actions
  end

  show title: :full_name do |a|
    attributes_table do
      row :full_name
      row :short_name
      row :state
      row :email
      row :website_url
      row :population_2017
      row :morph_name
      row :scraper_authority_label
      row :disabled
    end

    h3 "Last import run log"
    div do
      simple_format a.last_scraper_run_log
    end
  end

  filter :full_name

  form do |f|
    inputs "Name" do
      input :full_name
      input :short_name, input_html: { disabled: !f.object.new_record? },
                         hint: "Used to generate the authority URL and so shouldn't change once created"
    end
    inputs "Details" do
      input :state
      input :email
      input :website_url
      input :population_2017
    end
    inputs "Scraping" do
      input :morph_name, hint: "The name of the scraper at morph.io", placeholder: "planningalerts-scrapers/scraper-blue-mountains"
      input :scraper_authority_label, hint: "If the scraper above supports multiple authorities enter the authority_label used"
      input :disabled
    end
    actions
  end

  action_item :scrape, only: :show do
    button_to("Import applications", import_admin_authority_path)
  end

  member_action :import, method: :post do
    authority = Authority.find(params[:id])
    ImportApplicationsJob.perform_later(authority: authority)
    redirect_to({ action: :show }, notice: "Queued for importing!")
  end

  csv do
    column :full_name
    column :short_name
    column :disabled
    column :state
    column :email
    column :population_2017
    column :morph_name
    column(:number_of_applications) { |a| a.applications.count }
    column(:number_of_comments) { |a| a.comments.count }
  end

  permit_params :full_name, :short_name, :state, :email, :website_url, :population_2017, :morph_name, :scraper_authority_label, :disabled
end
