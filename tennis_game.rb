require "rspec/autorun"
require "byebug"
module Tennis
  class Score
    SCORES = ["Love", "Fifteen", "Thirty", "Fourty", "Point"]
    
    attr_reader :score_index
   
    def initialize
      @score_index = 0
    end

    def current
      self.class::SCORES[score_index]
    end

    def increment
      @score_index += 1
    end

    def decrement
      @score_index -= 1
    end

    def won?
      @score_index == self.class::SCORES.size-1
    end

    def self.tie
      SCORES[3]
    end
  end

  class TieScore < Score
    SCORES = ["Deuce", "Advantage Player", "Point"]

    def self.advantage
      SCORES[1]
    end

    def self.deuce
      SCORES[0]
    end
  end

  class Player

    attr_reader :name, :won
    attr_accessor :score

    def initialize(name)
      @name  = name
      @score = Score.new
    end

    def won?
      @score.won?
    end
  end

  class Round

    attr_reader :player1, :player2

    def initialize(player1, player2)
      @player1 = player1
      @player2 = player2
      @game    = Game.new(player1, player2)
      @tied    = false
    end

    def win_point(player)
      @game.win_point(player)

      if tied_reached?
        puts "Players reach #{TieScore.deuce}"
        @game = TieGame.new(@player1, @player2)
      end
    end

    def tied_reached?
      @tied = (@player1.score.current == Score.tie) && (@player2.score.current == Score.tie) && !@tied
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
      puts "\n#{player.name} scores!"
      puts ""
      puts "Scoreboard"
      puts "==========="
      puts "#{@player1.name} - #{@player1.score.current} : #{@player2.name} - #{@player2.score.current}"
      puts "==========="
      puts ""
    end

    def print_winner(player)
      puts "#{player.name} has won!"
    end

    private

    def players
      [@player1, @player2]
    end
  end

  class TieGame < Game

    def initialize(player1, player2)
      super
      @player1.score = TieScore.new
      @player2.score = TieScore.new
    end

    def win_point(player)
      other_player = (players - [player]).first
      if other_player.score.current == TieScore.advantage
        other_player.score.decrement
      else
        player.score.increment
      end

      print_score(player)

      if player.won?
        print_winner(player)        
      end
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

  describe Tennis::TieGame do
    it "decrements other player score if scoring player breaks advantage" do
      player1 = Tennis::Player.new("Bob")
      player2 = Tennis::Player.new("Jim")
      game = described_class.new(player1, player2)

      game.win_point(player1)
      expect(player1.score.current).to eql Tennis::TieScore.advantage
      game.win_point(player2)
      expect(player1.score.current).to eql Tennis::TieScore.deuce
      expect(player2.score.current).to eql Tennis::TieScore.deuce
    end
  end
end

@player1 = Tennis::Player.new("Bob")
@player2 = Tennis::Player.new("Jim")
@round    = Tennis::Round.new(@player1, @player2)

# Lets play a game!

@round.win_point(@player1)
@round.win_point(@player2)
@round.win_point(@player2)
@round.win_point(@player2)
@round.win_point(@player1)
@round.win_point(@player1)
@round.win_point(@player2)
@round.win_point(@player1)
@round.win_point(@player1)
@round.win_point(@player1)
