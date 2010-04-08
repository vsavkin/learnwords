require 'spec_helper'

describe Word do
  before(:each) do
    @valid_attributes = {
      :word => 'word',
      :explanation => 'some explanation',
      :show_at => Time.now.utc
    }
  end

  it "should create a new instance given valid attributes" do
    now = Time.now.utc - 1.second
    w = Word.create!(@valid_attributes)
    w.status.should == 'bad'
    (w.show_at >= now).should be_true
  end

  it "should require word, explanation fields" do
    w = Word.create(@valid_attributes.merge(:word => nil))
    w.should have(1).error_on(:word)

    w = Word.create(@valid_attributes.merge(:word => ''))
    w.should have(1).error_on(:word)

    w = Word.create(@valid_attributes.merge(:explanation => nil))
    w.should have(1).error_on(:explanation)

    w = Word.create(@valid_attributes.merge(:explanation => ''))
    w.should have(1).error_on(:explanation)
  end

  it "should reject invalid statuses" do
    w = Word.create(@valid_attributes.merge(:status => 'invalid'))
    w.should have(1).error_on(:status)
  end

  it "should set new status depending on previous status" do
    w = Word.create!(@valid_attributes)
    w.status.should == 'bad'
    w.update_status('good')
    
    w.status.should == Word.next_statuses['bad']['good']

    in_3_days = Time.now.utc + 3.day - 1.second
    (w.show_at >= in_3_days).should be_true
  end

  it "should normalize the presentation of a word" do
    w = Word.create(@valid_attributes.merge(:word => ' a    word   '))
    w.word.should == 'a word'
  end
end
