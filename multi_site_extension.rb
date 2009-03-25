require_dependency 'application'

class MultiSiteExtension < Spree::Extension
  version "1.0"
  description "Extention that will allow the store to support multiple sites each having their own taxonomies, products and orders"
  url "git://github.com/tunagami/spree-multi-site.git"

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
    Taxonomy.class_eval do
      belongs_to :site
      named_scope :by_site_with_descendants, lambda {|site| {:conditions => ["taxonomies.site_id in (?)", site.self_and_descendants]}}
    end

    Product.class_eval do
      belongs_to :site
      named_scope :by_site, lambda {|site| {:conditions => ["products.site_id = ?", site.id]}}
      named_scope :by_site_with_descendants, lambda {|site| {:conditions => ["products.site_id in (?)", site.self_and_descendants]}}
    end
    
    Order.class_eval do
      belongs_to :site
      named_scope :by_site_with_descendants, lambda {|site| {:conditions => ["orders.site_id in (?)", site.self_and_descendants]}}
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
      before_filter :get_site_and_products
      
      layout :get_layout
      
      def get_layout
        current_site.layout.empty? ? "application" : current_site.layout
      end

      def find_order      
        unless session[:order_id].blank?
          @order = Order.find_or_create_by_id(session[:order_id])
        else      
          @order = Order.create
        end
        @order.site = current_site
        session[:order_id] = @order.id
        @order
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
        default_stop = (Date.today + 1).to_s(:db)

        @search = Order.by_site_with_descendants(current_site).new_search(params[:search])

        if params[:search].nil? || params[:search][:conditions].nil?
          @search.conditions.checkout_complete = true
        end

        #set order by to default or form result
        @search.order_by ||= :created_at
        @search.order_as ||= "DESC"
        #set results per page to default or form result
        @search.per_page = Spree::Config[:orders_per_page]

        @collection = @search.find(:all, :include => [:user, :shipments, {:creditcards => :address}] )
     end
    end
    
    Admin::ReportsController.class_eval do
      def sales_total
        @search = Order.by_site_with_descendants(current_site).new_search(params[:search])
        #set order by to default or form result
        @search.order_by ||= :created_at
        @search.order_as ||= "DESC"

        @orders = @search.find(:all)    

        @item_total = @search.sum(:item_total)
        @ship_total = @search.sum(:ship_amount)
        @tax_total = @search.sum(:tax_amount)
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
        #use the active named scope only if the 'show deleted' checkbox is unchecked
        if params[:search].nil? || params[:search][:conditions].nil? || params[:search][:conditions][:deleted_at_is_not_null].blank?
          @search = end_of_association_chain.by_site_with_descendants(current_site).not_deleted.new_search(params[:search])
        else
          @search = end_of_association_chain.by_site_with_descendents(current_site).new_search(params[:search])
        end

        #set order by to default or form result
        @search.order_by ||= :name
        @search.order_as ||= "ASC"
        #set results per page to default or form result
        @search.per_page = Spree::Config[:admin_products_per_page]
        @search.include = :images
        @collection = @search.all
      end  
    end
  
    ProductsController.class_eval do    
      private
      def collection
        if params[:taxon]
          @taxon = Taxon.find(params[:taxon])

          @search = Product.active.by_site(current_site).scoped(:conditions =>
                                            ["products.id in (select product_id from products_taxons where taxon_id in (" +
                                              @taxon.descendents.inject( @taxon.id.to_s) { |clause, t| clause += ', ' + t.id.to_s} + "))"
                                            ]).new_search(params[:search])
        else
          @search = Product.active.by_site(current_site).new_search(params[:search])
        end

        @search.per_page = Spree::Config[:products_per_page]
        @search.include = :images

        @product_cols = 3
        @products ||= @search.all    
    
      end
    end
    
    TaxonsController.class_eval do
      private
      def load_data      
        @search = object.products.active.by_site(current_site).new_search(params[:search])
        @search.per_page = Spree::Config[:products_per_page]
        @search.include = :images

        @product_cols = 3
        @products ||= @search.all 
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