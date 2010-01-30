class MultiSiteHooks < Spree::ThemeSupport::HookListener 
  insert_after :admin_tabs do
    %(<%=  tab(:sites)  %>)
  end

  insert_after :admin_product_form_left do
    %(
    <% f.field_container :site do %>
      <%= f.label :site, t("site") %> <span class="required">*</span><br />
      <%= f.collection_select :site_id, @sites, :id, :name, {:include_blank => false} %>
      <%= f.error_message_on :site %>
    <% end %>    
    )
  end

  insert_after :admin_inside_taxonomy_form do
    %(
    <p>
      <%= label_tag "taxonomy_site_id", t("site") %><br />
      <%= error_message_on :taxonomy, :site %>
      <%= collection_select(:taxonomy, :site_id, @sites, :id, :name, {:include_blank => false}, {"style" => "width:200px"}) %> 
    </p>
    )
  end
  
  insert_before :admin_orders_index_headers do
    %(<th><%= order @search, :by => :site_name, :as => t("site") %></th>)
  end
  
  insert_before :admin_orders_index_rows do
    %(<td><%= ((order.site.name) if order.site) %></td>)
  end

end
