require "stringio"
require "logger"

module Autopong
  class Foul < StandardError; end
  class Let  < StandardError; end

  class Game
    attr_accessor :players, :scores, :current_server, :serves, :current_player, :state, :logger

    def initialize(p1, p2, logger=nil)
      @players = [p1, p2]
      @scores  = [0, 0]
      @state   = :serve
      @serves  = 0
      @logger  = logger || Logger.new(StringIO.new)
      set_server(players.sample)
    end

    # the ball bounced on a side of the table
    def ping(side, net=false)
      raise ArgumentError, "invalid side: #{side}. Valid values are 0 or 1" \
        unless [0, 1].include?(side)

      case state
      when :serve
        raise Foul if players[side] != current_server
        raise Let  if net
        self.state = :progress
        true

      when :progress
        # fail, dude let the ball bounce on his side twice
        if players[side] == current_player
          score_point(other_player)
          false

        # good move, now he has to send it back
        else
          self.current_player = other_player
          true
        end
      end
    end

    # the ball went outside the table
    def out
      score_point(other_player)
      return false
    end

    def set_server(player)
      self.current_server = self.current_player = player
    end

    def other_player
      (players - [current_player]).first
    end

    def other_server
      (players - [current_server]).first
    end

    def score_point(player)
      index = players.index(player)
      score = scores[index] += 1

      if winner
        self.state = :ended
        return
      end

      self.state = :serve
      self.current_player = current_server
      self.serves += 1

      if serves == 2 || (serves == 1 && scores.all? { |score| score >= 10 })
        self.serves = 0
        set_server(other_server)
      end
    end

    def winner
      low, high = scores.sort
      candidate = players[scores.index(high)]

      return nil if high < 11
      return candidate if high == 11 && low < 10
      return candidate if (high - low) >= 2
    end

    def set_winner(player)
      self.winner = player
      self.state  = :ended
    end

    def debug
      puts "---------"
      puts "  state:          #{state}"
      puts "  current player: #{current_player}"
      puts "  current server: #{current_server}"
      puts "  score:          #{scores.inspect}"
      puts "---------"
    end
  end

  class Player
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def to_s
      name
    end
  end
end
