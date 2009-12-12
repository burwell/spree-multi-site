require_dependency 'application_controller'

class MultiSiteExtension < Spree::Extension
  version "1.0"
  description "Extention that will allow the store to support multiple sites each having their own taxonomies, products and orders"
  url "git://github.com/kerinin/spree-multi-site.git"

  def activate
    # admin.tabs.add "Multi Site", "/admin/multi_site", :after => "Layouts", :visibility => [:all]

    # Update the page title to use the title name given at the site level
    ApplicationHelper.class_eval do
      def page_title
        title = @site.name || "Spree"
        unless @page_title.blank? 
          return "#{@page_title} - #{title}"
        end
        unless @product.nil?
          return "#{@product.name} - #{title}"
        end
        unless @taxon.nil?
          return "#{@taxon.name} - #{title}"
        end
        title
      end
    end

    #############################################################################
    # Overriding Spree Core Models
    
    for c in MultiSiteSystem.site_scoped_classes do
      c.class_eval do
        belongs_to :site
      
        table_name = c.table_name.to_s

        def site=(newsite)
          self.sites.delete
            
          if newsite
            newsite.inherit_from( self.class ).each do |s|
              sites << s
            end 
          end
          
          self.site_id = newsite.id
        end
      
        named_scope :by_site, lambda {|site| {:conditions => ["?.site_id = ?", table_name, site.id] }}
        named_scope :by_site_with_descendants, lambda {|site| {:conditions => ["?.site_id in (?)",table_name, site.self_and_descendants] }}
      end
    end

    #############################################################################
    

    #############################################################################
    # Overriding Spree Controllers
    ApplicationController.class_eval do
      include MultiSiteSystem
      def instantiate_controller_and_action_names
        @current_action = action_name
        @current_controller = controller_name
      end
    end
    
    Spree::BaseController.class_eval do
	    include MultiSiteSystem
      before_filter :get_site_and_products
      around_filter :scope_to_site
      
      layout :get_layout
      
      def get_layout
        current_site.layout.empty? ? "spree_application" : current_site.layout
      end

      def find_order      
        unless session[:order_id].blank?
          @order = Order.find_or_create_by_id(session[:order_id])
        else      
          @order = Order.create
        end
        @order.primary_site = current_site
        session[:order_id] = @order.id
        @order
      end
      
      private
      def scope_to_site(&block)
        scope_to_site_recursion MultiSiteSystem.site_scoped_classes.dup do block.call end
      end
      
      def scope_to_site_recursion(class_list, &block)
        if class_list.empty?
          yield
        else
          c = class_list.pop
          c.send(:with_scope, {
            #:find => { :conditions => ["?.site_id in (?)", c.name.tableize, @current_site.inherit_from( c ) ]},
	    :find => { :conditions => ["SELECT o.id FROM ? o WHERE EXISTS ( SELECT 1 FROM objects_sites s WHERE s.object_id = o.id AND s.site_id = ?",c.name.tableize, @current_site.id ] },
            :create => { :site => @current_site }
          }) { scope_to_site_recursion class_list do block.call end }
        end
      end
    end

    Admin::TaxonomiesController.class_eval do
      before_filter :load_data
      private
      def load_data
        @sites = current_site.self_and_descendants
      end
      
      def collection
        @collection = Taxonomy.by_site_with_descendants(current_site)     
      end
    end
    
    Admin::TaxonsController.class_eval do
      def available
        if params[:q].blank?
          @available_taxons = []
        else
          @available_taxons = current_site.taxons.scoped(:conditions => ['lower(taxons.name) LIKE ?', "%#{params[:q].downcase}%"])
        end
        @available_taxons.delete_if { |taxon| @product.taxons.include?(taxon) }
        respond_to do |format|
          format.html
          format.js {render :layout => false}
        end
      end
    end
    
    Admin::OrdersController.class_eval do
      private
      def collection
        #@search = Order.search(params[:search])
        @search = Order.by_site_with_descendants(current_site).search(params[:search])
        @search.order ||= "descend_by_created_at"

        # QUERY - get per_page from form ever???  maybe push into model
        # @search.per_page ||= Spree::Config[:orders_per_page]

        # turn on show-complete filter by default
        unless params[:search] && params[:search][:checkout_completed_at_not_null]
          @search.checkout_completed_at_not_null = true 
        end

        @collection = @search.paginate(:include  => [:user, :shipments, {:creditcard_payments => {:creditcard => :address}}],
                                       :per_page => Spree::Config[:orders_per_page], 
                                       :page     => params[:page])
      end      
      
    end
    
    Admin::ReportsController.class_eval do
            
      def sales_total
        @search = Order.by_site_with_descendants(current_site).search(params[:search])

        #set order by to default or form result
        @search.order ||= "descend_by_created_at"

        @orders = @search.find(:all)    

        @item_total = @search.sum(:item_total)
        @charge_total = @search.sum(:charge_total)
        @credit_total = @search.sum(:credit_total)
        @sales_total = @search.sum(:total)
      end
      
    end
    
    Admin::ProductsController.class_eval do
      before_filter :load_data
      private
      def load_data
        @sites = current_site.self_and_descendants
        @tax_categories = TaxCategory.find(:all, :order=>"name")  
        @shipping_categories = ShippingCategory.find(:all, :order=>"name")  
      end
      
      
      def collection
        base_scope = end_of_association_chain.by_site_with_descendants(current_site)

        # Note: the SL scopes are on/off switches, so we need to select "not_deleted" explicitly if the switch is off
        # QUERY - better as named scope or as SL scope?
        if params[:search].nil? || params[:search][:deleted_at_not_null].blank?
          base_scope = base_scope.not_deleted
        end

        @search = base_scope.search(params[:search])
        @search.order ||= "ascend_by_name"

        @collection = @search.paginate(:include  => {:variants => :images},
                                       :per_page => Spree::Config[:admin_products_per_page], 
                                       :page     => params[:page])
      end      
      
    end
  
    ProductsController.class_eval do    
      private      
      
      def collection
        base_scope = Product.active

        if !params[:taxon].blank? && (@taxon = Taxon.find_by_id(params[:taxon]))
          base_scope = base_scope.taxons_id_in_tree(@taxon)
        end

        @search = base_scope.search(params[:search])
        # might want to add .scoped(:select => "distinct on (products.id) products.*") here
        # in case some filter goes astray with its joins

        # this can now be set on a model basis 
        # Product.per_page ||= Spree::Config[:products_per_page]

        ## defunct?
        @product_cols = 3 

        @products ||= @search.paginate(:include  => [:images, {:variants => :images}],
                                       :per_page => params[:per_page] || Spree::Config[:products_per_page],
                                       :page     => params[:page])
      end
      
    end
    
    TaxonsController.class_eval do
      private
            
      def load_data
        @search = object.products.active.by_site(current_site).search(params[:search])

        ## push into model?
        ## @search.per_page ||= Spree::Config[:products_per_page]

        @products ||= @search.paginate(:include  => [:images, {:variants => :images}],
                                       :per_page => Spree::Config[:products_per_page],
                                       :page     => params[:page])
        ## defunct?
        @product_cols = 3
      end
            
    end
    #############################################################################
    
    
    #############################################################################
    # Overriding Spree Helpers
    TaxonsHelper.class_eval do
      def taxon_preview(taxon)
        products = taxon.products.by_site(current_site).active[0..4]
        return products unless products.size < 5
        if Spree::Config[:show_descendents]
          taxon.descendents.each do |taxon|
            products += taxon.products.by_site(current_site).active[0..4]
            break if products.size >= 5
          end
        end
        products[0..4]
      end
    end
    #############################################################################
  end
end
