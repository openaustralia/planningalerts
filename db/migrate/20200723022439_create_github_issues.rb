class CreateGithubIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :github_issues do |t|
      t.references :authority, foreign_key: true, type: :integer, null: false
      t.string :github_repo, null: false
      t.integer :github_number, null: false

      t.timestamps
    end
  end
end
