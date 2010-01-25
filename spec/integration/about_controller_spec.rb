require 'spec_helper'
require 'html_compare_helper'

describe AboutController do
  include HTMLCompareHelper
  fixtures :stats, :authority
  
  it "should render the page exactly the same as the php version" do
    compare_with_php("/about.php", "about")
  end
end
