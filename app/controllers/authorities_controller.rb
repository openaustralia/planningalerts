class AuthoritiesController < ApplicationController
  def broken
    @authorities = []
    Authority.all.each do |a|
      if a.latest_application
        @authorities << a
      end
    end
  end
end
