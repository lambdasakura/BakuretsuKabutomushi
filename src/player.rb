# -*- coding: utf-8 -*-
#
#  Playerの動作
#

class Player
  def initialize(x)
    @image = load_image("resource/image/nos_front.png")
    @x = x
    @y = SCREEN_H - @image.h
    @state = "alive"
    @recover = 0
    @count=0
    @font_s = SDL::TTF.open('resource/font/cinecaption226.ttf', 20)    
    @font_b = SDL::TTF.open('resource/font/cinecaption226.ttf', 22)    
    @timer = 0
    @muteki_counter = 0
  end

 def center
    cx = @x + (@image.w / 2)
    cy = @y + (@image.h / 2)

    [cx, cy]
  end

  def act(input,manager)
    @timer = 0 if @timer < 0
    @timer += 1

    case @state
    when "muteki"
      @muteki_counter +=1
      if @muteki_counter > 60
        @muteki_counter = 0
        @state = "alive"
      end
      @count=0
      @recover = 0
      @x -= 8 if input.left
      @x += 8 if input.right
      
      manager.tama_add(@x) if input.pushed?(:space)
      
      @x = 0 if @x < 0
      @x = SCREEN_W-@image.w if @x >= SCREEN_W-@image.w

    when "alive"
      @count=0
      @recover = 0
      @x -= 8 if input.left
      @x += 8 if input.right
      
      manager.tama_add(@x) if input.pushed?(:space)
      
      @x = 0 if @x < 0
      @x = SCREEN_W-@image.w if @x >= SCREEN_W-@image.w
    when "damaged"

      @recover += 1 if input.pushed?(:space)
      if @recover > (@timer / 90 ) + 5
        @state = "muteki"
      end
      
      @count += 1
      if @count > 180
        @state = "dying"
      end
    when "dying"
    when "dying2"
    when "dead"
    end
  end
  
  def render(screen)
    if @state == "dying" || @state == "dead" || @state == "dying2"
      return 
    end

    if @state == "muteki" || @state == "damaged"
      if (@timer % 2) == 1
        screen.put(@image,@x,@y)
      end
    else
      screen.put(@image, @x,@y)
    end

    if @state == "damaged"
      @font_b.draw_solid_utf8(screen, "#{@count/60}", @x, @y-30, 255, 255, 255)

    end
  end  
  attr_reader :x,:y
  attr_accessor :state ,:timer

end

