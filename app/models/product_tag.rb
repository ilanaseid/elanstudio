class ProductTag < ClearCMS::Content
  #form_field :display_hero, type: Boolean

  self.linked_content_filter={:types=>'Product'}

end