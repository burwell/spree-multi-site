require File.dirname(__FILE__) + '/../test_helper'
 
class SiteTest < Test::Unit::TestCase
	for HClass in MultiSiteSystem.site_scoped_classes do
			context "A #{HClass.name} in a site hierarchy" do
				setup do
					@base = Factory.create(:site)
					@branch1 = Factory.create(:site)
					@branch2 = Factory.create(:site)
					@leaf = Factory.create(:site)
					
					@branch1.move_to_child_of @base
					@branch2.move_to_child_of @base
					@leaf.move_to_child_of @branch1
					
					@instance = Factory.create( HClass.name.downcase, :site => @branch1)
				end
				
				should "have an associated site" do
					assert_equal( @branch1, @instance.site )
				end
				
				should "show up in the local list from the associated site" do
					assert HClass.by_site( @branch1 ).all.include? @instance
				end
				
				should "show up in the full list from the parent site" do
					assert HClass.by_site_with_descendants( @base ).all.include? @instance
				end
				
				should "not show up in either list from a leaf site" do
					assert  !HClass.by_site( @leaf ).all.include?( @instance)
					assert  !HClass.by_site_with_descendants( @leaf ).all.include?( @instance)
				end
				
				should "not show up in either list from adjacent branch sites" do
					assert  !HClass.by_site( @branch2 ).all.include?( @instance)
					assert  !HClass.by_site_with_descendants( @branch2 ).all.include?( @instance)
				end
			end
	end
end