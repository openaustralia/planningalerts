require 'spec_helper'
require 'html_compare_helper'

describe FaqController do
  include HTMLCompareHelper
  
  it "should render the faq" do
    compare_with_php("/faq.php", "faq")
  end
end
