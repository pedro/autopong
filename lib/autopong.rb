module Autopong
  class Foul < StandardError; end
  class Let  < StandardError; end

  class Game
    attr_accessor :players, :scores, :current_server, :serves, :current_player, :state

    def initialize(p1, p2)
      @players = [p1, p2]
      @scores  = [0, 0]
      @state   = :new
      @serves  = 0
      set_server(players.sample)
    end

    # the ball bounced on a side of the table
    def ping(side, net=false)
      raise ArgumentError, "invalid side: #{side}. Valid values are 0 or 1" \
        unless [0, 1].include?(side)

      case state
      when :new
        raise Foul if players[side] != current_server
        raise Let  if net
        self.state = :progress

      when :progress
        # fail, dude let the ball bounce on his side twice
        if players[side] == current_player
          score_point(other_player)

        # good move, now he has to send it back
        else
          self.current_player = other_player
        end
      end
    end

    # the ball went outside the table
    def out
      case state
      when :new
        score_point(other_player)

      when :progress
        score_point(other_player)
      end
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
      scores[index] += 1
      self.state = :new
      self.serves += 1

      if serves == 2
        self.serves = 0
        set_server(other_server)
      end
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
