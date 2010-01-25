class AboutController < ApplicationController
  def index
    @page_title = "About"
    @menu_item = "about"
    
    @authorities = ["Ararat Rural City Council, VIC", "Ballarat City Council, VIC", "Banyule City Council, VIC",
      "Blacktown City Council, NSW", "Blue Mountains City Council, NSW", "Boroondara City Council, VIC",
      "Brimbank City Council, VIC", "Brisbane City Council, QLD", "Caboolture District, Moreton Bay Regional Council, QLD",
      "Caloundra, Sunshine Coast Regional Council, QLD", "Cardinia Shire Council, VIC", "Casey City Council, VIC",
      "Central Goldfields Shire Council, VIC", "City of Greater Dandenong, VIC", "City of Greater Geelong, VIC",
      "City of Sydney, NSW", "Darebin City Council, VIC", "Frankston City Council, VIC", "Gannawarra Shire Council, VIC",
      "Glenelg Shire Council, VIC", "Gold Coast City Council, QLD", "Golden Plains Shire Council, VIC",
      "Greater Shepparton City Council, VIC", "Hepburn Shire Council, VIC", "Hobsons Bay City Council, VIC",
      "Logan City Council, QLD", "Manningham City Council, VIC",
      "Maroochydore and Nambour offices, Sunshine Coast Regional Council, QLD", "Maroondah City Council, VIC",
      "Melbourne City Council, VIC", "Minister for Planning, VIC", "Mitchell Shire Council, VIC",
      "Moonee Valley City Council, VIC", "Moreland City Council, VIC", "Moyne Shire Council, VIC",
      "Noosa, Sunshine Coast Regional Council, QLD", "Pine Rivers District, Moreton Bay Regional Council, QLD",
      "Port Phillip City Council, VIC", "Pyrenees Shire Council, VIC", "Randwick City Council, NSW",
      "Redcliffe District, Moreton Bay Regional Council, QLD", "Shire of Melton, VIC",
      "Southern Grampians Shire Council, VIC", "Surf Coast Shire Council, VIC", "Sutherland Shire Council, NSW",
      "Warrnambool City Council, VIC", "Wellington Shire Council, VIC", "Whittlesea City Council, VIC",
      "Woollahra Municipal Council, NSW", "Wyndham City Council, VIC", "Yarra City Council, VIC"]
      
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end
