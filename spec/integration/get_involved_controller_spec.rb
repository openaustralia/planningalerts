require 'spec_helper'
require 'html_compare_helper'

describe GetInvolvedController do
  include HTMLCompareHelper
  fixtures :stats, :authority
  
  it "should render the page exactly the same as the php version" do
    compare_with_php("/getinvolved.php", "getinvolved")
  end
end
