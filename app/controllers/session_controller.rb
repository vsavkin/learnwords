class SessionController < ApplicationController
  def register_user
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash[:message] = 'You are successfully registered'
      session[:user_id] = @user.id
      redirect_to :controller => 'decks', :action => 'list'
    end
  end

  def login
    if request.post?
      current_user = User.find_by_login_and_password(params[:login], params[:password])
      if current_user
        session[:user_id] = current_user.id
        if session[:return_to]
          redirect_to session[:return_to]
          session[:return_to] = nil
        else
          redirect_to :controller => 'decks', :action => 'list'
        end
      else
        flash[:error] = 'The login/password pair is invalid'
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to '/'
  end
end
