class DecksController < ApplicationController
  before_filter :logging_required, :retrive_decks

  def list
    @deck = Deck.new
  end

  def show
    @deck = current_user.find_deck(params[:id].to_i)
    if !@deck
      flash[:error] = 'There is no deck with such ID'
      redirect_to controller: 'main', action: 'index'
    end
    @other_decks = current_user.decks - [@deck]
  end

  def create
    @deck = current_user.create_deck(params[:deck])
    if @deck.save
      redirect_to controller: 'decks', action: 'show', id: @deck.id
    else
      render action: 'list'
    end
  end

  def edit
    @deck = current_user.find_deck(params[:id].to_i)
    if @deck
      if @deck.update_attributes(params[:deck])
        render action: 'show'
      else
        render template: 'decks/show'
      end
    else
      redirect_to controller: 'main', action: 'index'
      flash[:error] = 'There is no deck with such ID'
    end
  end

  def delete
    deck = current_user.find_deck(params[:id].to_i)
    current_user.delete_deck(deck)
    flash[:message] = "Your deck '#{deck.name}' is successfully deleted"
    redirect_to controller: 'decks', action: 'list'
  end

  private
  def retrive_decks
    @decks = current_user.decks(true)
  end
end
