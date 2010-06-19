class ShareController < ApplicationController
  before_filter :logging_required

  def list_public_decks
    @decks = Deck.all_public
  end

  def copy_deck
    deck = Deck.find_by_id(params[:id])
    current_user.copy(deck)
    flash[:message] = "Deck is successfuly copied"
    redirect_to(action: 'list_public_decks')
  end
end
