require 'spec_helper'
require 'html_compare_helper'

describe SignupController do
  include HTMLCompareHelper
  
  it "should render the home page exactly the same as the php version" do
    compare_with_php("/", "home")
  end
end
