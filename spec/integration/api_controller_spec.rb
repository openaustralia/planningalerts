require 'spec_helper'
require 'html_compare_helper'

describe ApiController do
  include HTMLCompareHelper
  fixtures :stats, :authority, :application
  
  it "should render the howto page exactly the same as the php version" do
    compare_with_php("/apihowto.php", "apihowto")
  end
  
  it "should render one of the api examples the same as php" do
    compare_with_php("/api.php?call=address&address=24+Bruce+Road+Glenbrook,+NSW+2773&area_size=4000", "api_4000")
  end

  it "should render one of the api examples with a narrower search the same as php" do
    compare_with_php("/api.php?call=address&address=24+Bruce+Road+Glenbrook,+NSW+2773&area_size=2000", "api_2000")
  end
  
  it "should render the api lookup by authority the same as php" do
    compare_with_php("/api.php?call=authority&authority=Wombat", "api_authority")
  end
end
