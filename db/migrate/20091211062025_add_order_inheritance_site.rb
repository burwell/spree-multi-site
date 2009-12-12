class AddOrderInheritanceSite < ActiveRecord::Migration
  def self.up
	  add_column :sites, :ancestors_inherit_orders, :boolean, :default => true
	  add_column :sites, :descendants_inherit_orders, :boolean, :default => false
  end

  def self.down
	  remove_column :sites, :ancestors_inherit_orders
	  remove_column :sites, :descendants_inherit_orders
  end
end
