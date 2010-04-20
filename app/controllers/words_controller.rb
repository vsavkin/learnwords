require 'net/http'
require 'uri'

class WordsController < ApplicationController
  before_filter :logging_required

  def initialize
    @facade = OaldParser::Facade.create_facade
    @important_words_dict = Lew::ImportantWordsDict.read_from_file
  end

  def edit
    @word = Word.find_by_id(params[:id])
    if !@word || !@current_user.has_word(@word)
      flash[:error] = 'There is no such word'
      render template: 'words/close', layout: false
      return
    end

    if request.post? && @word.update_attributes(params[:word])
      render template: 'words/close', layout: false
    else
      render template: 'words/word', layout: false
    end
  end

  def create
    @deck_id = params[:deck_id].to_i
    if request.post?
      deck = Deck.find_by_id(@deck_id)
      @word = deck.create_word(params[:word])
      @word.show_at = Time.zone.now
      if @word.save
        render template: 'words/close', layout: false
        return
      end
    end
    render template: 'words/word', layout: false
  end

  def retrieve_word_description
    render text: description(params[:str])
  rescue Exception => e
    render nothing: true, status: 404
  end

  def check_word_importance
    if important? params[:str]
      render text: 'IMPORTANT'
    else
      render nothing: true, status: 400  
    end
  end

  private
  def description(str)
    @facade.describe(str: str)
  end

  def important?(str)
    word = OaldParser::WordExtractor.new.extract(str)
    @important_words_dict.important_word? word
  end
end
