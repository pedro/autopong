require "test_helper"

describe Game do
  before do
    @p1 = Player.new("John Malkovich")
    @p2 = Player.new("Edward Norton")
    @game = Game.new(@p1, @p2)
  end

  it "starts on state new" do
    @game.state.must_equal :new
  end

  it "has a current player randomly picked to start the game" do
    [@p1, @p2].must_include @game.current_player
  end

  describe "on a new game" do
    before do
      @game.current_player = @p1
    end

    describe "when the ball starts in the wrong side of the table" do
      it "raises a foul" do
        lambda { @game.ping(1) }.must_raise(Foul)
      end
    end

    describe "when the ball starts in the right side" do
      it "moves state to progress" do
        @game.ping(0)
        @game.state.must_equal :progress
      end

      it "changes current player" do
        @game.ping(0)
        @game.current_player.must_equal @p2
      end
    end
  end
end
