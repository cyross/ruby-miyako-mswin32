#encoding: UTF-8

require 'character_state'

module ActionGame
  class Character
    #:stop : �L�����N�^��~��
    #:walk : ���s��
    #:run  : �_�b�V����
    #:jump : �W�����v��
    PATTERNS = [:stop, :walk, :run, :jump]

    attr_writer :scrolling
    
    def initialize(map)
      @now = :stop
      size = Miyako::Size.new(64,64)
      @dia = StateFactory.create(size)
      @collision = Miyako::Collision.new(Miyako::Rect.new(0,0,*size))
      @map = map
      #�������H
      @falling = false
      #�X�N���[�����H
      @scrolling = false
      #�X�N���[���J�n���[�ʒu
      
      #�X�N���[���J�n�E�[�ʒu

      #�X�N���[�����H

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
  
    # amount : �ړ���(-1/0/1)
    # btn1   : �{�^���P��������Ă���H(true/false)
    # btn2   : �{�^���Q��������Ă���H(true/false)
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
