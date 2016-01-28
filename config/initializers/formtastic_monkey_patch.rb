module Formtastic
  module Inputs
    module Base
      module Wrapping
        def input_wrapping(&block)
          template.content_tag(:li,
            [error_html, hint_html, template.capture(&block)].join("\n").html_safe,
            wrapper_html_options
          )
        end
        #.....
      end
      module Labelling
        def label_text
          (requirement_text + (localized_label || humanized_method_name)).html_safe
        end
      end
    end
  end
end

