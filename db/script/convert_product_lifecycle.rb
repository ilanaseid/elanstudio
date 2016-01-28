# change 'Archived' to 'Sold Out' for system flag
# change all published products that are not 'Archived' to 'Current'
# change all published products that are 'Coming Soon' to 'Preview'
# change all 'Archived' and technically sold out items to 'Discontinued'....or just gift boxes??
# 
# change "available_date" to the current published date


puts 'Starting product lifecycle conversion...'

puts 'Updating system flag to "Sold Out" for published products with 0 stock'
Product.update_all(system_flag: nil)
Product.published.each do |p|
  p.update_attributes(system_flag: 'Sold Out') if p.out_of_stock?
end


puts 'Setting exclusive=true for items with flag="Exclusive"'
Product.where(:flag=>'Exclusive').update_all(exclusive: true)


puts 'Setting product state="preview" for items with flag="Coming Soon"'
Product.where(:flag=>'Coming Soon').update_all(:product_state=>'Preview')


puts 'Setting product state="discontinued" for items with brightpearl_brand_id=137 aka The Line'
Product.where(:brightpearl_brand_id=>137).update_all(:product_state=>'Discontinued')


puts 'Setting product state="current" for published items that do not have a product state and are not system flag = sold out'
Product.published.where(:product_state.in=>[nil,'Current']).each do |p|
  p.product_state='Current'
  p.available_date=p.publish_at
  p.save
end
