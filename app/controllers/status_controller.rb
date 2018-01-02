class StatusController < ApplicationController
  def new
    @project = Project.find(params[:project_id])
    @status = Status.new
  end

  def create
    @status = Status.new(status_params)
    @status.project_id = params[:project_id]
    @status.save
    redirect_to @status.project
  end

  private

    def status_params
      params.require(:status).permit(:name, :order)
    end
end
