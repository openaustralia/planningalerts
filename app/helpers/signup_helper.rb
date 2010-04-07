module SignupHelper
  def open_preview_window(size)
    url = preview_url(:address => @alert.address, :area_size => @zone_sizes[size])
    "javascript:document.open('#{url}', 'name', 'width=525,height=570');"
  end
end
