require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    session[:total_score] = 0 unless session[:total_score]
    @alphabet = *('A'..'Z')
    @vowels = %w[A E I O U]
    @consonnants = %w[B C D F G H J K L M N P Q R S T V W X Y Z]
    @letters = []
    @start_time = DateTime.now.to_time.to_i
    5.times do
      @letters << @vowels.sample
    end
    5.times do
      @letters << @consonnants.sample
    end
    @letters.shuffle!
    @letters
  end

  def score
    @elapsed_time = DateTime.now.to_time.to_i - params[:start_time].to_i
    @message = ''
    @score = 0
    @guessedword = params[:guessedword].upcase
    if !valid?(@guessedword, params[:value].split(' '))
      @message = "Sorry but #{@guessedword} can't be built out of #{params[:value]}"
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
    session[:total_score] += @score
  end

  def clear
    reset_session
    redirect_to new_path
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
