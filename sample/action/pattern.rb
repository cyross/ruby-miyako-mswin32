#encoding: utf-8

module ActionGame
  module Pattern
    def Pattern.create(sprite_file_name, size, wait)
      spr = Miyako::Sprite.new(:file=>sprite_file_name, :type=>:ac)
      spr.ow, spr.oh = size.to_a
      return Miyako::SpriteAnimation.new(:sprite=>spr, :wait=>wait)
    end
  end
end