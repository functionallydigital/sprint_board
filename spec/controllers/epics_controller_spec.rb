require 'rails_helper'

RSpec.describe EpicsController, type: :controller do

  context "as a logged in user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      log_in @user
      @project = FactoryGirl.create(:project)
      FactoryGirl.create(:project_user, user_id: @user.id, project_id: @project.id)
    end

    it "should return a list of projects" do
      check_get_request @user, :index, :success
    end

    # it "should not allow access to the index for proactive or registration teams" do
    #   check_get_request @user, :index, :unauthorized, team: "proactive"
    #   check_get_request @user, :index, :unauthorized, team: "registration"
    # end

    # it "should not allow access to edit functions" do
    #   check_get_request @user, :temporary_index, :unauthorized
    #   check_get_request @user, :edit_overall, :unauthorized, team: "framework"
    # end
  end

  private

    def check_get_request(method, status, opts = {})
      get method, opts
      expect(response).to have_http_status(status)
    end
end
