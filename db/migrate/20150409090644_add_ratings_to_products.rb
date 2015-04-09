class AddRatingsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :ratings, :integer, array: true, default: '{}'

    add_index :products, :ratings, using: 'gin'
  end
end
