#encoding: UTF-8

require 'character_state'

module ActionGame
  class Character
    #:stop : キャラクタ停止中
    #:walk : 歩行中
    #:run  : ダッシュ中
    #:jump : ジャンプ中
    PATTERNS = [:stop, :walk, :run, :jump]

    attr_writer :scrolling
    
    def initialize(map)
      @now = :stop
      size = Miyako::Size.new(64,64)
      @dia = StateFactory.create(size)
      @collision = Miyako::Collision.new(Miyako::Rect.new(0,0,*size))
      @map = map
      #落下中？
      @falling = false
      #スクロール中？
      @scrolling = false
      #スクロール開始左端位置
      
      #スクロール開始右端位置

      #スクロール中？

    end

    def scrolling?
      return @scrolling
    end

    def start
      @dia.start
    end

    def stop
      @dia.stop
    end

    def update
      @dia.update
    end
  
    # amount : 移動量(-1/0/1)
    # btn1   : ボタン１が押されている？(true/false)
    # btn2   : ボタン２が押されている？(true/false)
    def update_input(amount, btn1, btn2)
      @dia.update_input(amount, btn1, btn2)
    end
  
    def render
      @dia.render
    end
  
    def dispose
      @dia.dispose
    end
  end
end
