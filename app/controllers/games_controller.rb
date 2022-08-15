require 'open-uri'
require 'json'

class GamesController < ApplicationController


  @@alphabet = *('A'..'Z')

  def new
    @letters = []
    @start_time = DateTime.now.to_time.to_i
    10.times do
      @letters << @@alphabet.sample
    end
    @letters
  end

  def score
    @elapsed_time = DateTime.now.to_time.to_i - params[:start_time].to_i
    @message = ''
    @score = 0
    @guessedword = params[:guessedword].upcase
    if !valid?(@guessedword, params[:value].split(' '))
      @message = "Sorry but #{@guessedword} can't be built out of #{@initial_grid.join(', ')}"
    elsif !in_dictionnary?(@guessedword)
      @message = "Sorry but #{@guessedword} doesn't seem to be a valid English word..."
    else
      @message = "Congratulations! #{@guessedword} is a valid English word! "
      @score = if @guessedword.size * 2 - (@elapsed_time / 5) > 1
                 @guessedword.size * 2 - (@elapsed_time / 5)
               else
                 1
               end

    end
  end

  private

  def valid?(word, grid)
    @word_array = word.upcase.split('')
    @initial_grid = grid
    @grid = grid
    @word_array.each do |letter|
      return false unless grid.include?(letter)

      @grid.delete_at(@grid.find_index(letter))
    end
    true
  end

  def in_dictionnary?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_serialized = URI.open(url).read
    word_info = JSON.parse(word_serialized)
    word_info['found']
  end
end
