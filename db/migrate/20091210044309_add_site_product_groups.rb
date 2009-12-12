class AddSiteProductGroups < ActiveRecord::Migration
  def self.up
	add_column :product_groups, :site_id, :integer
  end

  def self.down
	 remove_column :product_groups, :site_id
  end
end