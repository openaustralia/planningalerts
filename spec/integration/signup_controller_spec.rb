require 'spec_helper'
require 'html_compare_helper'

describe SignupController do
  include HTMLCompareHelper
  fixtures :stats, :authority
  
  it "should render the home page exactly the same as the php version" do
    compare_with_php("/", "home")
  end
  
  it "should render the preview page the same as the php version" do
    loc = Location.new(-33.772609, 150.624263)
    Location.should_receive(:geocode).with("24 bruce road, glenbrook, NSW 2773").and_return(loc)
    loc.should_receive(:box_with_size_in_metres).with(200).and_return(
      [Location.new(-33.773508234721, 150.62309060152), Location.new(-33.771709765279, 150.62543539848)])
    compare_with_php("/preview.php?address=24%20bruce%20road,%20glenbrook,%20NSW%202773&area_size=200", "preview")
  end
  
  it "should render the check mail page the same as the php version" do
    compare_with_php("/checkmail.php", "checkmail")
  end
end
