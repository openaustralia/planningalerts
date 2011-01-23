class Hash

  # Remove nil and empty keys.
  def compact
    delete_if { |key, value| value.blank? }
  end

end