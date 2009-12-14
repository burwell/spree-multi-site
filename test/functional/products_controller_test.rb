require File.dirname(__FILE__) + '/../test_helper'
 
class ProductsControllerTest < ActionController::TestCase
  for anc, des in [[true, true], [true,false], [false,true], [false,false]] do
    context "On get to Product :index with ancestors_inherit #{anc} and descendants_inherit #{des}" do
      setup do
        @parent = Factory.create(:site, :name=>'parent', :ancestors_inherit_products => anc, :descendants_inherit_products => des)
        @site = Factory.create(:site, :name=>'site', :parent => @parent, :ancestors_inherit_products => anc, :descendants_inherit_products => des)
        @sibling = Factory.create(:site, :name=>'sibling', :parent => @parent, :ancestors_inherit_products => anc, :descendants_inherit_products => des)
        @child = Factory.create(:site , :name=>'child', :parent => @site, :ancestors_inherit_products => anc, :descendants_inherit_products => des)
        @leaf = Factory.create(:site , :name=>'leaf', :parent => @child, :ancestors_inherit_products => anc, :descendants_inherit_products => des)
        
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
 
      should "include site products" do
        assert assigns["products"].include? @site_product
      end
      
      should "exclude sibling products" do
        assert !( assigns["products"].include? @sibling_product )
      end
      
      should "#{des ? 'include' : 'exclude'} include parent products" do
        assert_equal des, assigns["products"].include?( @parent_product )
      end
    
      should "#{anc ? 'include' : 'exclude'} child products" do
        assert_equal anc, assigns["products"].include?( @child_product )
      end
        
      should "#{anc ? 'include' : 'exclude'} leaf products" do
        assert_equal anc, assigns["products"].include?( @leaf_product )
      end
    end
  end
end