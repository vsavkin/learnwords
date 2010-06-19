class LearnController < ApplicationController
  def show_word
    @deck = current_user.find_deck(params[:deck_id])
    if @deck.nil?
      flash[:error] = 'There is no deck with such ID'
      redirect_to(controller: 'main', action: 'index')
    else
      @word = @deck.random_word
      if @word
        render(template: 'learn/show')
      else
        render(template: 'learn/all_repeated')
      end
    end
  end

  def answer
    @word = Word.find_by_id(params[:id])
    unless @word && current_user.has_word(@word)
      flash[:error] = 'There is no word with such ID'
      redirect_to(controller: 'main', action: 'index')
    else
      @with_answer = true
      render(template: 'learn/show')
    end
  end

  def update_status
    word = Word.find_by_id(params[:word_id])
    if current_user.has_word(word)
      word.update_status(params[:status])
      redirect_to(action: 'show_word', deck_id: word.deck.id)
    else
      flash[:error] = 'There is no word with such ID'
      redirect_to(controller: 'main', action: 'index')
    end
  end
end
