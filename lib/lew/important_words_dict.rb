require 'oald_parser'

module Lew
  class ImportantWordsDict
    def initialize(words)
      @words = words
    end

    def important_word?(word)
      @words.include? word
    end

    def self.read_from_file(filename = 'list3000.txt')
      path = "#{File.dirname(__FILE__)}/#{filename}"
      @words = File.open(path, "r", encoding: 'UTF-8').read.split("\n")
      ImportantWordsDict.new(@words)
    end
  end
end