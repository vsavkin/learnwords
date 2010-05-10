require 'spec_helper'

describe ShareController do

  before(:each) do
    @user = mock_model(User)
    @deck = mock_model(Deck)
    Deck.stub!(:find_by_id).and_return(@deck)
    controller.stub!(:current_user).and_return @user
  end

  it "should show the list of public decks" do
    Deck.should_receive(:all_public).and_return([@deck])
    get 'list_public_decks'
    assigns[:decks].should == [@deck]
  end

  it "should be able to copy a deck" do
    @user.should_receive(:copy).with(@deck)
    post 'copy_deck', id: @deck.id 
    flash[:message].should_not be_nil
    response.should redirect_to(controller: 'share', action: 'list_public_decks')
  end
end
