module RSocks

  STATE_LIST = [:handshake, :auth, :start]

  class StateMachine

    attr_reader :current_state

    def initialize
      @max = 2
      @state_num = 0
      @current_state = RSocks::STATE_LIST[@state_num]
    end

    def handshake?
      current_state == :handshake
    end

    def auth?
      current_state == :auth
    end

    def start?
      current_state == :start?
    end

    def auth!
      @state_num = 1
      @current_state = RSocks::STATE_LIST[@state_num]
    end

    def start!
      @state_num = 2
      @current_state = RSocks::STATE_LIST[@state_num]
    end

    def state_changed
      @state_num += 1 unless @state_num >= @max
      @current_state = RSocks::STATE_LIST[@state_num]
    end
  end
end