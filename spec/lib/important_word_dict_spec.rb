require 'spec_helper'

describe Lew::ImportantWordsDict do
  it "should check whether some word added to dict or not" do
    dict = Lew::ImportantWordsDict.new(['one', 'two'])
    dict.important_word?('one').should be_true
    dict.important_word?('three').should be_false
  end

  it "should be able to read all the words from a file" do
    dict = Lew::ImportantWordsDict.read_from_file('test_file.txt')
    dict.important_word?('one').should be_true
    dict.important_word?('three').should be_false
  end
end