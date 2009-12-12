Factory.define :asset do |a|
end

Factory.define :calculator do |c|
end

Factory.define :configuration do |c|
end

Factory.define :coupon do |c|
        c.code "Test Code"
end

Factory.define :option_type do |o|
	o.name "Option Type Name"
  o.presentation "presentation"
end

Factory.define :order do |o|
end

Factory.define :preference do |o|
        o.attribute "Test attribute"
        o.owner_id 10
        o.owner_type "Test Owner Type"        
end

Factory.define :product do |p|
 p.name "Product Name"
 p.description "Description"
 p.price 100
 p.count_on_hand 1
 p.available_on Time.gm '1990'
end

Factory.define :product_group do |p|
	p.name "Product Group Name"
	p.permalink "product_group"
end

Factory.define :prototype do |p|
	p.name "Prototype Name"
end

Factory.define :property do |p|
	p.name "Property Name"
end

Factory.define :shipping_category do |s|
        s.name "Test name"
end

Factory.define :shipping_method do |s|
end

Factory.define :site do |f|
  f.name "Site Name"
  f.sequence(:domain) {|n| "domain#{n}.com" }
  f.layout "spree_application"
  f.ancestors_inherit_products true
  f.descendants_inherit_products true
end

Factory.define :tax_category do |t|
        t.name "Test name"
end

Factory.define :taxonomy do |t|
	t.name "Taxonomy Name"
end

Factory.define :variant do |v|
        v.price 100.00
end

Factory.define :zone do |z|
        # NOTE: this is being validated for uniqueness, which will cause problems in sites
        # maybe append the site id to the front of the zone and then strip it off?
        z.name { Factory.next( :zone ) }
end