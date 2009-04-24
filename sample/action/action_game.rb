#encoding: UTF-8
require 'Miyako/miyako'

require 'mapman'
require 'pattern'
require 'character'

Miyako::Screen.fps = 30

class MainScene
  include Miyako::Story::Scene

  def init
    sprite = Miyako::Sprite.new(:file=>"image/bg.png", :type=>:as)
    @bg = Miyako::Plane.new(:sprite=>sprite)
    @map = ActionGame::Map.new
    @chr = ActionGame::Character.new(@map)
  end
  
  def setup
    @chr.start
  end
  
  def update
    return nil if Miyako::Input.quit_or_escape?
    @chr.update_input(
      Miyako::Input.trigger_amount[0],
      Miyako::Input.trigger_any?(:btn1),
      Miyako::Input.trigger_any?(:btn2)
    )
    @chr.update
    @map.move(16,16)
    @now
  end
  
  def final
    @chr.stop
  end
  
  def render
    @bg.render
    @map[0].render
    @chr.render
    @map[1].render
  end

end

story = Miyako::Story.new
story.run(MainScene)
