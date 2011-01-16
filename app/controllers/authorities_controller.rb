class AuthoritiesController < ApplicationController
  def broken
    @authorities = []
    Authority.all.each do |a|
      if a.latest_application
        @authorities << a
      end
    end
    @authorities.sort! { |a,b| a.latest_application <=> b.latest_application }
  end
end
