class SprintsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @sprint = Sprint.find(params[:id])
  end
end
