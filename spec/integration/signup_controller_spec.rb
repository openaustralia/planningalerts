require 'spec_helper'
require 'html_compare_helper'

describe SignupController do
  include HTMLCompareHelper
  fixtures :stats, :authority
  
  it "should render the home page exactly the same as the php version" do
    compare_with_php("/", "home")
  end
  
  it "should render the preview page the same as the php version" do
    compare_with_php("/preview.php?address=24%20bruce%20road,%20glenbrook,%20NSW%202773&area_size=200", "preview")
  end
end
