class AddTaxonomyInheritanceSite < ActiveRecord::Migration
  def self.up
	  add_column :sites, :ancestors_inherit_taxonomies, :boolean, :default => true
	  add_column :sites, :descendants_inherit_taxonomies, :boolean, :default => false
  end

  def self.down
	  remove_column :sites, :ancestors_inherit_taxonomies
	  remove_column :sites, :descendants_inherit_taxonomies
  end
end
