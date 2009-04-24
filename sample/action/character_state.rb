#encoding: UTF-8

module ActionGame
  #今回は、Miyako勉強のため、キャラクタ状態ディスパッチャを実装するために
  #Diagramを用意する
  
  module StateMethods
    def init_state_methods(spr)
      @sprite = spr
      @@dir = 1 # 方向
      @@params = nil
      @@position = @sprite.pos
    end
    
    def start
      # 位置情報を引き継ぎ
			@sprite.character = @@dir
      @sprite.move_to(@@position[0], @@position[1])
      @sprite.start
    end
    
    def stop
      @sprite.stop
      # 位置情報を引き継ぎ
      @@position.move_to(*@sprite.pos.to_a)
    end

    def update_input(*params)
      @@params = params
      case(@@params[0])
      when -1
        @@dir = 1
      when 1
        @@dir = 2
      end
			@sprite.character = @@dir
    end

    def update
      @sprite.update_animation
    end

    def render
      @sprite.render
    end
  end
  
  # 停止中
  class StoppingNode
    include Miyako::Diagram::NodeBase
    include StateMethods

    def initialize(size)
			@state = :stop
      self[:sprite] = Pattern.create("image/uma_stop.png",size,0)
      init_state_methods(self[:sprite])
    end
    
    def dispatch
      return :stopping unless @@params
      return :walking if @@params[0] != 0
      return :jumping if @@params[1]
      return :running if @@params[2] && @@params[0] != 0
      return :stopping
    end
  end

  # 歩行中
  class WalkingNode
    include Miyako::Diagram::NodeBase
    include StateMethods

    def initialize(size)
			@state = :walk
      self[:sprite] = Pattern.create("image/uma_walk.png",size,10)
      init_state_methods(self[:sprite])
    end

    def update
      self[:sprite].update_animation
      self[:sprite].move(@@params[0] * 4, 0)
    end

    def dispatch
      return :walking unless @@params
      return :stopping if @@params[0] == 0
      return :jumping if @@params[1]
      return :running if @@params[2]
      return :walking
    end
  end

  # ダッシュ中
  class RunningNode
    include Miyako::Diagram::NodeBase
    include StateMethods

    def initialize(size)
			@state = :run
      self[:sprite] = Pattern.create("image/uma_walk.png",size,5)
      init_state_methods(self[:sprite])
    end

    def update
      self[:sprite].update_animation
      self[:sprite].move(@@params[0] * 8, 0)
    end

    def dispatch
      return :running unless @@params
      return :stopping if @@params[0] == 0
      return :walking unless @@params[2]
      return :jumping if @@params[1]
      return :running
    end
  end

  # ジャンプ中
  class JumpingNode
    include Miyako::Diagram::NodeBase
    include StateMethods

    def initialize(size)
			@state = :jump
      self[:sprite] = Pattern.create("image/uma_jump.png",size,20)
      init_state_methods(self[:sprite])
    end

    def dispatch
      return :jumping unless @@params
      return :stopping unless @@params[1]
      return :jumping
    end
  end

  #ノード名とノードクラスの対
  NodePairs = [
    # 停止中
    [:stopping, StoppingNode],
    # 歩行中
    [:walking, WalkingNode],
    # 走行中
    [:running, RunningNode],
    # ジャンプ中
    [:jumping, JumpingNode]
  ]

  # ファクトリクラス
  class StateFactory
    def StateFactory.create(size)
      diagram = Miyako::Diagram::Processor.new{|dia|
        # 各ノードの作成
        NodePairs.each{|pair| dia.add pair[0], pair[1].new(size) }
        NodePairs.map{|pair| pair[0]}.each{|name_from|
          NodePairs.map{|pair| pair[0]}.each{|name_to|
            next if name_from == name_to
            dia.add_arrow(name_from, name_to){|from| from.dispatch == name_to}
          }
        }
      }
      def diagram.call(method, *params, &block)
        NodePairs.each{|pair| self[pair[0]][:sprite].__send__(method, *params, &block)}
      end
      return diagram
    end
  end
end
