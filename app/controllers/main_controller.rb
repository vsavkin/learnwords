class MainController < ApplicationController
  def index
    if current_user
      @words = current_user.random_words(5)
    end
  end
end
