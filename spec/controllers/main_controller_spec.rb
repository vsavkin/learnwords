require 'spec_helper'

describe MainController do    
  
  it "should show 5 words from users dictionary if user is logged in" do  
    word_list = ['word1', 'word2']
    @user = mock_model(User)
    @user.stub!(:random_words).and_return word_list
    controller.stub!(:current_user).and_return @user
    
    get 'index'
    assigns[:words].should == word_list
  end
end
