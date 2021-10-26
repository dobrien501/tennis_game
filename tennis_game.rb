require "rspec/autorun"

module Tennis
  class Score
    SCORES = ["Love", "Fifteen", "Thirty", "Fourty", "Point"]
    
    attr_reader :score_index
   
    def initialize
      @score_index = 0
    end

    def current
      SCORES[score_index]
    end

    def increment
      @score_index += 1
    end

    def decrement
      @score_index -= 1
    end

    def won?
      @score_index == SCORES.size-1
    end
  end

  class Player

    attr_reader :name, :score, :won

    def initialize(name)
      @name  = name
      @score = Score.new
    end

    def won?
      @score.won?
    end

  end

  class Game
    attr_reader :player1, :player2

    def initialize(player1, player2)
      @player1 = player1
      @player2 = player2
    end

    def win_point(player)
      
      unless player.won?      
        player.score.increment
        print_score(player)
      end

      if player.won?
        print_winner(player)
      end
    end

    def print_score(player)
      puts "#{player.name} scores #{player.score.current}"
    end

    def print_winner(player)
      puts "#{player.name} has won!"
    end

    private

    def players
      [@player1, @player2]
    end
  end
end

# BEGIN SPECS
RSpec.describe "Tennis Game" do

  describe Tennis::Score do
    it "starts at Love" do
      expect(described_class.new.current).to eql "Love"
    end

    it "moves up and down the tennis scoring system" do
      score = described_class.new
      score.increment
      expect(score.current).to eql "Fifteen"
      
      score.increment
      expect(score.current).to eql "Thirty"

      score.increment
      expect(score.current).to eql "Fourty"

      score.increment
      expect(score.current).to eql "Point"

      score.decrement
      expect(score.current).to eql "Fourty"

      score.decrement
      expect(score.current).to eql "Thirty"

      score.decrement
      expect(score.current).to eql "Fifteen"

      score.decrement
      expect(score.current).to eql "Love"
    end
    
    it "marks score as won if reached end of scoring system" do
      score = described_class.new
      expect(score.won?).to be_falsy
      (described_class::SCORES.size - 1).times { score.increment }
      expect(score.won?).to be_truthy
    end
  end

  describe Tennis::Player do
    it "has a score" do
      player = described_class.new(name: "Bob")
      expect(player.score.is_a?(Tennis::Score)).to be_truthy
    end
  end

  describe Tennis::Game do
    it "has two players" do
      player1 = Tennis::Player.new("Bob")
      player2 = Tennis::Player.new("Jim")
      game = described_class.new(player1, player2)
      expect(game.player1.name).to eql "Bob"
      expect(game.player2.name).to eql "Jim"
    end
  end
end

@player1 = Tennis::Player.new("Bob")
@player2 = Tennis::Player.new("Jim")
@game    = Tennis::Game.new(@player1, @player2)

# Lets play a game!

@game.win_point(@player1)
@game.win_point(@player2)
@game.win_point(@player2)
@game.win_point(@player2)
@game.win_point(@player2)
