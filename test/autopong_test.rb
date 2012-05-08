require "test_helper"

describe Game do
  before do
    @p1 = Player.new("p1")
    @p2 = Player.new("p2")
    @game = Game.new(@p1, @p2)
  end

  it "starts on state new" do
    @game.state.must_equal :new
  end

  it "has a current player randomly picked to start the game" do
    [@p1, @p2].must_include @game.current_server
  end

  it "also considers the player serving to be the current" do
    @game.current_server.must_equal @game.current_player
  end

  describe "on a new game" do
    before do
      @game.set_server(@p1)
    end

    describe "when the ball starts in the wrong side of the table" do
      it "raises a foul" do
        lambda { @game.ping(1) }.must_raise(Foul)
      end
    end

    describe "when the ball starts in the right side" do
      before { @game.ping(0) }

      it "moves state to progress" do
        @game.state.must_equal :progress
      end

      it "accumulates a serve" do
        @game.serves.must_equal 1
      end
    end

    describe "when the ball hits the net" do
      it "raises a let" do
        lambda { @game.ping(0, true) }.must_raise(Let)
      end
    end

    describe "the ball goes out" do
      before { @game.out }

      it "is a score for the other player" do
        @game.scores.must_equal [0, 1]
      end
    end
  end

  describe "on a game in progress" do
    before do
      @game.state = :progress
      @game.set_server(@p1)
    end

    describe "when the ball hits the same side again" do
      before { @game.ping(0) }

      it "considers it a score for the other player" do
        @game.scores.must_equal [0, 1]
      end

      it "goes back to state new" do
        @game.state.must_equal :new
      end
    end

    describe "when the ball hits the other side" do
      before { @game.ping(1) }

      it "keeps the game in progress" do
        @game.state.must_equal :progress
      end

      it "flips the current player" do
        @game.current_player.must_equal @p2
      end

      it "doesn't change the score" do
        @game.scores.must_equal [0, 0]
      end
    end

    describe "when the ball hits the net" do
      it "ignores" do
        @game.ping(1, true) # should not raise
      end
    end

    describe "the ball goes out" do
      before { @game.out }

      it "is a point for the other player" do
        @game.scores.must_equal [0, 1]
      end

      it "goes back to state new" do
        @game.state.must_equal :new
      end
    end
  end

  describe "integration test" do
    it "handles a full match" do
      @game.set_server(@p2)
      @game.state.must_equal :new

      # first point
      @game.ping(1)
      @game.state.must_equal :progress
      @game.ping(0)
      @game.state.must_equal :progress
      @game.ping(1)
      @game.state.must_equal :progress
      @game.ping(1) # failed to return
      @game.scores.must_equal [1, 0]
      @game.current_server.must_equal @p2

      # second point
      @game.ping(1)
      @game.ping(0)
      @game.ping(0)
      @game.scores.must_equal [1, 1]
      @game.current_server.must_equal @p1

      # third point, let
      lambda { @game.ping(0, true) }.must_raise(Let)
      @game.scores.must_equal [1, 1]
      @game.current_server.must_equal @p1

      # third point
      @game.ping(0)
      @game.ping(1)
      @game.ping(0)
      @game.ping(0)
      @game.scores.must_equal [1, 2]
      @game.current_server.must_equal @p1

      # fourth, p1 serves out
      @game.out
      @game.scores.must_equal [1, 3]
      @game.current_server.must_equal @p2

      # fifth, p2 serves out (after bouncing on his side)
      @game.ping(1)
      @game.out
      @game.scores.must_equal [2, 3]
      @game.current_server.must_equal @p2

      # sixth, p2 serves and p1 returns out
      @game.ping(1)
      @game.ping(0)
      @game.out
      @game.scores.must_equal [2, 4]
      @game.current_server.must_equal @p1
    end
  end
end
