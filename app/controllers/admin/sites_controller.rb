class Admin::SitesController< Admin::BaseController
  resource_controller
  
  create.after do
    object.move_to_child_of current_site
    current_user.roles << Role.create(:name => "admin_" + @site.name)
  end
 
  private
  def collection
    @collection ||= current_site.self_and_children
  end
end