class PagesController < ApplicationController
  def offline
    render 'offline', layout: false
  end
end
