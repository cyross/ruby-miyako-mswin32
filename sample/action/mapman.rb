#encoding: UTF-8

module ActionGame
  class Map

    attr_writer :scrolling
    attr_reader :scroll_amount
  
    def initialize
      @blocks  = Miyako::MapChipFactory.load("csv/block.csv")
      @grasses = Miyako::MapChipFactory.load("csv/grass.csv")
      @manager = Miyako::MapEventManager.new
      @map = Miyako::Map.new([@blocks,@grasses], "csv/map.csv", @manager)
      @scrolling = false

      # スクロール開始・終了境界を設定(画面サイズの半分が境界)
      scroll_border = Miyako::Screen.w / 2
      @scroll_border = {
        :left  => scroll_border, # 左端
        :right => @map.size[0] * @map.chip_size[0] - scroll_border # 右端
      }
      @scroll_amount = 4 # スクロール量
    end

    def update
      
    end
    
    # スクロール可能？
    def scrolling?
      return @scrolling
    end

    # マップ上位置移動
    def move(x, y)
      @map.move(x, y)
      return self
    end
    def move_to(x, y)
      @map.move_to(x, y)
      return self
    end

    # レイヤーオブジェクト取得
    def [](idx)
      return @map[idx]
    end
  end
end