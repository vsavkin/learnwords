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
    if !@word || !current_user.has_word(@word)
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

  def delete
    word = Word.find_by_id(params[:id])
    if !word || !current_user.has_word(word)
      flash[:error] = 'There is no such word'
      redirect_to controller: 'main', action: 'index'
    else
      word.destroy
      redirect_to controller: 'decks', action: 'show', id: word.deck.id
    end
  end

  def delete_all
    words = params[:id].collect{|id| Word.find_by_id(id)}
    if words.empty?
      redirect_to controller: 'main', action: 'index'
      return
    end

    if strange_word = words.find{|w| !current_user.has_word w}
      flash[:error] = "There is no such word #{strange_word.id}"
      redirect_to controller: 'main', action: 'index'
    else
      deck = words[0].deck
      words.each{|w| w.destroy}
      redirect_to controller: 'decks', action: 'show', id: deck.id 
    end
  end

  def move_word
    params[:id]
    params[:deck_id]
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
    desciption = description(params[:str])
    unless desciption.empty?
      render text: desciption
    else
      render nothing: true, status: 404
    end
  rescue Exception => e
    puts e.message
    render nothing: true, status: 404
  end

  def check_word_importance
    if important? params[:str]
      render text: 'true'
    else
      render text: 'false'
    end
  end

  def find_similar_words
    deck_id = params[:deck_id].to_i
    deck = Deck.find_by_id(deck_id)
    similar_words = deck.similar_words(params[:str]).map{|w| w.word}
    render json: similar_words
  end

  def test
    Net::HTTP.post_form(URI.parse("http://www.oup.com/oald-bin/web_getald7index1a.pl"), search_word: 'dog')
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
