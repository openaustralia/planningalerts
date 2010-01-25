require 'spec_helper'
require 'html_compare_helper'

describe ApiHowtoController do
  include HTMLCompareHelper
  fixtures :stats, :authority
  
  it "should render the page exactly the same as the php version" do
    compare_with_php("/apihowto.php", "apihowto")
  end
end
