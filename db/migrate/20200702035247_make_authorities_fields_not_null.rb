class MakeAuthoritiesFieldsNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :authorities, :disabled, false
    change_column_null :authorities, :state, false
  end
end
