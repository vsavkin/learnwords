class WordsController < ApplicationController
  before_filter :logging_required

  def edit
    @word = Word.find_by_id(params[:id])
    if !@word || !@current_user.has_word(@word)
      flash[:error] = 'There is no such word'
      render :template => 'words/close', :layout => false
      return
    end

    if request.post? && @word.update_attributes(params[:word])
      render :template => 'words/close', :layout => false
    else
      render :layout => false
    end
  end

  def create
    @deck_id = params[:deck_id].to_i
    if request.post?
      deck = Deck.find_by_id(@deck_id)
      @word = deck.create_word(params[:word])
      @word.show_at = Time.now
      if @word.save
        render :template => 'words/close', :layout => false
        return
      end
    end
    render :layout => false
  end
end
