class DropVanityTables < ActiveRecord::Migration[5.2]
  def change
    drop_table "vanity_conversions" do |t|
      t.integer "vanity_experiment_id"
      t.integer "alternative"
      t.integer "conversions"
      t.index ["vanity_experiment_id", "alternative"], name: "by_experiment_id_and_alternative"
    end

    drop_table "vanity_experiments" do |t|
      t.string "experiment_id"
      t.integer "outcome"
      t.datetime "created_at"
      t.datetime "completed_at"
      t.index ["experiment_id"], name: "index_vanity_experiments_on_experiment_id"
    end

    drop_table "vanity_metric_values" do |t|
      t.integer "vanity_metric_id"
      t.integer "index"
      t.integer "value"
      t.string "date"
      t.index ["vanity_metric_id"], name: "index_vanity_metric_values_on_vanity_metric_id"
    end

    drop_table "vanity_metrics" do |t|
      t.string "metric_id"
      t.datetime "updated_at"
      t.index ["metric_id"], name: "index_vanity_metrics_on_metric_id"
    end

    drop_table "vanity_participants" do |t|
      t.string "experiment_id"
      t.string "identity"
      t.integer "shown"
      t.integer "seen"
      t.integer "converted"
      t.index ["experiment_id", "converted"], name: "by_experiment_id_and_converted"
      t.index ["experiment_id", "identity"], name: "by_experiment_id_and_identity"
      t.index ["experiment_id", "seen"], name: "by_experiment_id_and_seen"
      t.index ["experiment_id", "shown"], name: "by_experiment_id_and_shown"
      t.index ["experiment_id"], name: "index_vanity_participants_on_experiment_id"
    end
  end
end
