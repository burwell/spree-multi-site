module MultiSiteSystem
  def current_site
    @current_site ||= (get_site_from_request || get_site_from_session || Site.first || Site.new(:name => "No Site"))
  end

  def current_site=(new_site)
    session[:site_id] = new_site.nil? ? nil : new_site.id
    @current_site = new_site || :false
  end

  def get_site_from_request
    self.current_site = Site.find(:first, :conditions => ["domain = ? OR domain = ?", request.host, request.domain])
  end

  def get_site_from_session
    self.current_site = Site.find(session[:site_id]) if session[:site_id]
  end

  def get_site_and_products
    @site = current_site
    @taxonomies = (@site ? @site.taxonomies : [])
  end
end
