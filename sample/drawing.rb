#! /usr/bin/ruby

require 'Miyako/miyako'

include Miyako

sprite = Sprite.new(:size => [256,256], :type => :ac)
Drawing.rect(sprite, Rect.new(100, 100, 100, 50), [0, 128, 0], :fill)

Miyako.main_loop do
	break if Input.quit_or_escape?
	sprite.render
end
