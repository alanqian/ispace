class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.string :name
      t.integer :job_id
      t.string :stat_type
      t.string :category_id
      t.integer :plan_set_id
      t.string :rel_model
      t.integer :agg_id
      t.integer :num_positions
      t.integer :run
      t.integer :num_facings
      t.decimal :outcome, precision: 15, scale: 4
      t.decimal :percentage, precision: 5, scale: 1

      t.timestamps
    end
  end
end
