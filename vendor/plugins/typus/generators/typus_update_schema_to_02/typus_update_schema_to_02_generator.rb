class TypusUpdateSchemaTo02Generator < Rails::Generator::Base

  def manifest

    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', { :migration_file_name => 'update_typus_schema_to_02' }
    end

  end

end