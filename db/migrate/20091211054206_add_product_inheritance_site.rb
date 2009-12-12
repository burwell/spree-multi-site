class AddProductInheritanceSite < ActiveRecord::Migration
  def self.up
	  add_column :sites, :ancestors_inherit_products, :boolean, :default => true
	  add_column :sites, :descendants_inherit_products, :boolean, :default => false
  end

  def self.down
	  remove_column :sites, :ancestors_inherit_products
	  remove_column :sites, :descendants_inherit_products
  end
end
