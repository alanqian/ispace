class RefineProductProps < ActiveRecord::Migration
  def change
    add_column :products, :abbr_name, :string
    add_column :products, :en_name, :string
    add_column :products, :unit, :string
    add_column :products, :pack_units, :integer
    add_column :products, :sale_season, :string
    add_column :products, :shelf_life, :integer
    add_column :products, :tax_type, :string
    add_column :products, :input_price, :decimal, precision: 15, scale: 4
    add_column :products, :input_price_with_tax, :decimal, precision: 15, scale: 4
    add_column :products, :input_tax_ratio, :decimal, precision: 5, scale: 3
    add_column :products, :output_tax_ratio, :decimal, precision: 5, scale: 3
    add_column :products, :input_sale_price, :decimal, precision: 15, scale: 4
    add_column :products, :input_member_price, :decimal, precision: 15, scale: 4
    add_column :products, :shelf_life_input, :integer
    add_column :products, :shelf_life_dist, :integer
    add_column :products, :available, :integer
    add_column :products, :status, :integer
  end
end
