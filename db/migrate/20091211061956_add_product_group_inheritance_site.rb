class AddProductGroupInheritanceSite < ActiveRecord::Migration
  def self.up
	  add_column :sites, :ancestors_inherit_product_groups, :boolean, :default => true
	  add_column :sites, :descendants_inherit_product_groups, :boolean, :default => false
  end

  def self.down
	  remove_column :sites, :ancestors_inherit_product_groups
	  remove_column :sites, :descendants_inherit_product_groups
  end
end
