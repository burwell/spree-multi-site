require File.dirname(__FILE__) + '/../test_helper'
 
class SiteTest < Test::Unit::TestCase

	context "A taxon in a site hierarchy" do
		setup do
			@base = Factory.create(:site)
			@branch1 = Factory.create(:site)
			@branch2 = Factory.create(:site)
			@leaf = Factory.create(:site)
			
			@branch1.move_to_child_of @base
			@branch2.move_to_child_of @base
			@leaf.move_to_child_of @branch1
			
			@taxonomy = Factory.create(:taxonomy, :site => @branch1)
		end
		
		should "return taxonomy values" do
			assert @taxonomy.name
		end
	end
end