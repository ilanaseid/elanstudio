class Brand < ClearCMS::Content
  #form_field :brand_name
  #form_field :brand_url
  form_field :location, :formtastic_options=>{:label=>'Origin / Lives'}
  form_field :designer
  form_field :founder
  form_field :established, :formtastic_options=>{:label=>'Year Est. / Born'}
  form_field :artist, type: Boolean, :formtastic_options=>{:label=>'An Artist?'}
  form_field :hide_from_designer_index, type: Boolean
  form_field :brightpearl_brand_id, :type=>Integer, :formtastic_options=>{:input_html=>{:disabled=>'true'}}

  has_many :products

#   def related_content(count)
#     site.contents.published.where(_type: 'Editorial').limit(count)
#   end

  def related_stories(count)
    product_ids=self.products.published.pluck(:id).collect(&:to_s)
    stories=self.site.contents.published.where(:'linked_contents.linked_content_id'.in=>product_ids).where(:_type.in=>['Chapter','Footnote']).without_options.desc(:publish_at).limit(count)
  end

  def self.published_product_brands_by_category
    map = %Q{
      function() {
              emit(this.brand_id, this.categories);
             }
         }

    reduce = %Q{
      function(key, values) {
        var result = { categories: [] };
        values.forEach(function(value) {
          value.forEach(function(category) {
            if(result.categories.indexOf(category) < 0) {
              result.categories = result.categories.concat(category);
            }
          });
        });
        return result;
      }
    }

    Product.published.without_options.map_reduce(map,reduce).out(inline:true)
  end

end
