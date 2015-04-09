class AddJsonMetadata < ActiveRecord::Migration
  def change
    add_column :products, :metadata, :json, default: {}, null: false
  end
end
