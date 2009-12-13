class Site < ActiveRecord::Base
  include CollectiveIdea::Acts::NestedSet
  #include SymetrieCom::Acts::NestedSet
	 
  has_many :taxonomies
  has_many :products
  has_many :orders
  has_many :taxons, :through => :taxonomies
  #( MultiSiteSystem.site_scoped_classes do |cls| cls.name.tableize end )
  
  has_many_polymorphs :objects, :from => [:products, :product_groups, :orders, :taxonomies]

  validates_presence_of   :name, :domain, :layout
  validates_uniqueness_of :domain
  acts_as_nested_set
  
  def self_and_children
    [self] + children
  end
  
  def inherit_from( cls )
    ancestors.scoped( :conditions => [ "sites.descendants_inherit_#{cls.name.tableize} == ?", true ] ) + [self] + descendants.scoped( :conditions => ["sites.ancestors_inherit_#{cls.name.tableize} == ?", true ] )
    #ancestors.find( :conditions => [ "sites.descendants_inherit_#{cls.name.tableize} == ?", true ] ) + [self] + descendants.find( :conditions => ["sites.ancestors_inherit_#{cls.name.tableize} == ?", true ]  ) 
  end
end
