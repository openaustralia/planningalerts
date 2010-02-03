require 'spec_helper'
require 'html_compare_helper'

describe ApiController do
  include HTMLCompareHelper
  fixtures :authority, :application
  
  it "should render one of the api examples the same as php" do
    compare_with_php("/api.php?call=address&address=24+Bruce+Road+Glenbrook,+NSW+2773&area_size=4000", "api")
  end
end
