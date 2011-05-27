class AuthoritiesController < ApplicationController
  def broken
    @authorities = []
    Authority.active.each do |a|
      if a.latest_application
        @authorities << a
      end
    end
    @authorities.sort! { |a,b| a.latest_application <=> b.latest_application }
  end
end
