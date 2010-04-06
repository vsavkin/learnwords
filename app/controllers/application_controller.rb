class ApplicationController < ActionController::Base
  helper :all
  before_filter :fetch_logged_in, :except => [:fetch_logged_in, :logging_required]
  helper_method :logging_required
  protect_from_forgery

  def fetch_logged_in
    return unless session[:user_id]
    @current_user = User.find_by_id(session[:user_id])
  end

  def logging_required
    return true if logged_in?
    session[:return_to] = request.request_uri
    redirect_to(:controller => 'session', :action => 'login') and return false
  end

  private
  def logged_in?
    ! @current_user.nil?
  end
end
