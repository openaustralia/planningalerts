require 'spec_helper'
require 'html_compare_helper'

describe StaticController do
  include HTMLCompareHelper
  fixtures :stats, :authority
  
  it "should render the page exactly the same as the php version" do
    compare_with_php("/about.php", "about")
  end

  it "should render the faq" do
    compare_with_php("/faq.php", "faq")
  end

  it "should render the page exactly the same as the php version" do
    compare_with_php("/getinvolved.php", "getinvolved")
  end
end
