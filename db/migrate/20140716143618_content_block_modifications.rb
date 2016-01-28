class ContentBlockModifications < ActiveRecord::Migration
  def up
  	ProductFeature.each do |pf|
  		cb=pf.content_block 'raw'
  		cb.body=%Q(<div class="row-fluid">#{cb.body}</div>)
  		cb.save
  	end

  	Page.each do |page|
  		cb=page.content_block 'raw'
  		if cb 
  			page.content_blocks.create(type: 'hero', body: cb.body)
  		end
  		
  		cb=page.content_block 'description'
  		if cb 
  			cb.type='stories_feature'
  			cb.save
  		end

  		cb=page.content_block 'details'
  		if cb
  			cb.type='objects_feature'
  			cb.save
  		end
  	end

  end

  def down
  end
end
