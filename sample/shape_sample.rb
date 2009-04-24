require 'Miyako/miyako'

sprite = Miyako::Shape.circle(ray: 100)
sprite2 = Miyako::Shape.polygon(vertexes: [[100,100],[150,100],[200,200]], color: [255,0,0])

loop do
  Miyako::Input.update
  break if Miyako::Input.quit_or_escape?
  sprite.render
  sprite2.render
  Miyako::Screen.render
end
