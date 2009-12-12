require File.dirname(__FILE__) + '/../test_helper'
 
class ProductsControllerTest < ActionController::TestCase
	context "On get to :show" do
		setup do
			@parent = Factory.create(:site)
			@site = Factory.create(:site )
			@child1 = Factory.create(:site )
			@child2 = Factory.create(:site )
			@leaf = Factory.create(:site )
			
			# NOTE: these have to be built from the bottom up!
			@leaf.move_to_child_of @child1
			@child1.move_to_child_of @site
			@child2.move_to_child_of @site
			@site.move_to_child_of @parent
			
			# NOTE: add some products
      @parent_product = Factory.create(:product, :site => @parent)
      @site_product = Factory.create(:product, :site => @site)
      @child1_product = Factory.create(:product, :site=>@child1)
      @child2_product = Factory.create(:product, :site=>@child2)
      @leaf_product = Factory.create(:product, :site=>@leaf)
      
			@request.host = @site.domain
			
			get :index
		end
			

    #should_assign_to :user
    #should_respond_with :success
    #should_render_template :show
    #should_not_set_the_flash
		
		should "products should be filtered" do
      assert assigns["products"].include? @site_product
      assert assigns["products"].include? @child1_product
      assert assigns["products"].include? @leaf_product
      assert !( assigns["products"].include? @parent_product )
		end
	end
end