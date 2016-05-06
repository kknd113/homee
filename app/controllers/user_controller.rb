class UserController < ApplicationController
  
  def logs
    find_user
    user_logs = @user.conversations.pluck(:text)
    last_updated = @user.conversations.last.updated_at
    render json: {facebook_id: @user.fb_id, logs: user_logs, updated_at: last_updated}
  end
  
  def find_user
    @user = User.find_by_id params[:id]
  end
end
