require File.dirname(__FILE__) + '/../test_helper'
 
class ProductsControllerTest < ActionController::TestCase
	context "On get to :show" do
		setup do
			@parent = Factory.create(:site, :name=>'parent')
			@site = Factory.create(:site, :name=>'site', :parent => @parent)
      @sibling = Factory.create(:site, :name=>'sibling', :parent => @parent)
			@child = Factory.create(:site , :name=>'child', :parent => @site)
			@leaf = Factory.create(:site , :name=>'leaf', :parent => @child)
      
      @parent.reload
      @site.reload
      @sibling.reload
      @child.reload
			
			# NOTE: add some products
      @parent_product = Factory.create(:product, :site => @parent)
      @site_product = Factory.create(:product, :site => @site)
      @sibling_product = Factory.create(:product, :site=>@sibling)
      @child_product = Factory.create(:product, :site=>@child)
      @leaf_product = Factory.create(:product, :site=>@leaf)
      
			@request.host = @site.domain
			
			get :index
		end
			
    teardown do
      Site.delete_all
    end
    
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
    should "assign current site" do
      assert_equal assigns["current_site"], @site
    end
		
    should "include parent products" do
      assert assigns["products"].include? @parent_product
    end
    
    should "include site products" do
      assert assigns["products"].include? @site_product
    end
    
    should "exclude sibling products" do
      assert !( assigns["products"].include? @sibling_product )
    end
    
    should "include child products" do
      assert assigns["products"].include? @child_product
    end
      
    should "include leaf products" do
      assert assigns["products"].include? @leaf_product
    end
	end
end