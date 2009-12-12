require File.dirname(__FILE__) + '/../test_helper'
 
class ScopeTest < Test::Unit::TestCase
	context "A scoped product (inherit: ancestors, descendants)" do
		setup do
			@parent = Factory.create(:site)
			@site = Factory.create(:site )
			@sibling = Factory.create(:site )
			@child = Factory.create(:site )
			@leaf = Factory.create(:site )
			
			# NOTE: these have to be built from the bottom up!
			@leaf.move_to_child_of @child
			@child.move_to_child_of @site
			@site.move_to_child_of @parent
			@sibling.move_to_child_of @parent
			
			@product = Factory.create(:product)
			
			@product.site = @site
		end
		
		should "have a primary site" do
			assert_equal @site, @product.site
		end
		
		should "show up in the associated site's products" do
			#assert @site.products.include? @product
			assert @product.sites.include? @site
		end
		
		should "not show up in sibling site's products" do
			#assert !( @sibling.products.include? @product )
			assert !( @product.sites.include? @sibling )
		end
		
		should "include the associated site in its scopings" do
			assert @product.sites.include? @site
		end
		
		should "also be scoped to the site's ancestors" do
			assert @product.sites.include? @parent
		end
		
		should "also be scoped to the the site's descendants" do
			assert @product.sites.include? @child
			assert @product.sites.include? @leaf
		end
	end
	
	context "A scoped product (inherit: ancestors)" do	
		
		should "show up in the associated site's products" do
			
		end
		
		should "not show up in sibling site's products" do
			
		end
		
		should "include the associated site in its scopings" do
			
		end
		
		should "not be scoped to the site's ancestors" do
			
		end
		
		should "also be scoped to the site's descendants" do
			
		end
	end
	
	context "A scoped product (inherit: descendants)" do	
		
		should "show up in the associated site's products" do
			
		end
		
		should "not show up in sibling site's products" do
			
		end
		
		should "include the associated site in its scopings" do
			
		end
		
		should "also be scoped to the site's ancestors" do
			
		end
		
		should "not be scoped to the site's descendants" do
			
		end
	end
	
	context "A scoped product (inherit: none)" do	
		
		should "show up in the associated site's products" do
			
		end
		
		should "not show up in sibling site's products" do
			
		end
		
		should "include the associated site in its scopings" do
			
		end
		
		should "not be scoped to the site's ancestors" do
			
		end
		
		should "not be scoped to the site's descendants" do
			
		end
	end
end