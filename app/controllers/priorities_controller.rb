class PrioritiesController < ApplicationController
  def index
    render :json => Priority::PRIORITY_LEVELS
  end
end
