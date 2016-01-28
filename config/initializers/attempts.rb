class Integer
  def attempts(*errors)
    errors = [StandardError] if errors.empty?
    i = 0
    begin
      yield i
    rescue *errors
      i += 1
      retry if i < self
      raise
    end
  end
end
