require 'spec_helper'
require 'html_compare_helper'

describe ApiController do
  include HTMLCompareHelper
  fixtures :stats, :authority, :application
  
  it "should render one of the api examples the same as php" do
    compare_with_php("/api.php?call=point&lat=-33.772609&lng=150.624263&area_size=4000", "api_4000")
  end

  it "should render one of the api examples with a narrower search the same as php" do
    compare_with_php("/api.php?call=point&lat=-33.772609&lng=150.624263&area_size=2000", "api_2000")
  end
  
  it "should render the api lookup by authority the same as php" do
    compare_with_php("/api.php?call=authority&authority=Wombat", "api_authority")
  end
end
