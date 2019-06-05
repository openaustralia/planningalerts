class AddScraperAuthorityLabelToAuthorities < ActiveRecord::Migration[5.2]
  def change
    add_column :authorities, :scraper_authority_label, :string,
               comment: "For scrapers for multiple authorities filter by this label"
  end
end
