class RelationshipsController < ApplicationController
  before_action :logged_in_user
  
  def create
    # @following_user = User.find(params[:followed_id])
    # @user = current_user
    # return if @user.following?(@following_user)
    # @user.follow(@following_user)
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html {redirect_to @following_user}
      format.turbo_stream
    end
  end

  def destroy
    @user = current_user.following.find(params[:followed_id])
    current_user.unfollow(@user)
    respond_to do |format|
      format.html {redirect_to @user}
      format.turbo_stream
    end
  end
end