ThinkingSphinx::Index.define :application, with: :active_record do
  indexes description
  has date_scraped
end
