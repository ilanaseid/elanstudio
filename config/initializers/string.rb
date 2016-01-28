module Sanitization
  refine String do
    def sanitize
      gsub(/[^0-9a-z., ]/i, '')
    end
  end
end
