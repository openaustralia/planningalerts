class AuthoritiesController < ApplicationController
  def broken_scrapers
    @authorities = []
    Authority.all.each do |a|
      if a.latest_application
        @authorities << a
      end
    end
  end
end
