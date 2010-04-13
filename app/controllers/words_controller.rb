class WordsController < ApplicationController
  before_filter :logging_required

  def initialize(facade = OaldParser::Facade.create_facade)
    @facade = facade
  end

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
      @word.show_at = Time.zone.now
      if @word.save
        render :template => 'words/close', :layout => false
        return
      end
    end
    render :layout => false
  end


  def retrieve_word_description
    description = @facade.describe(str: params[:str])
    render text: description
  rescue Exception => e
    puts e.inspect
    render nothing: true, status: 404
  end
end
