#! /usr/bin/ruby

require 'Miyako/miyako'
require 'Miyako/EXT/slides'

Miyako::Screen.set_size(800,600)

back  = Miyako::Sprite.new(:size=>Miyako::Screen.size, :type=>:ac).fill([128,0,0])
slide = Miyako::Slide["half-white"].centering

Miyako.main_loop do
  break if Miyako::Input.quit_or_escape?
  back.render
  slide.render
end