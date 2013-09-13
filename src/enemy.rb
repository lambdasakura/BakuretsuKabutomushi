class Enemy < Character
  
  def initialize
    @image = load_image("resource/image/enemy.png")
    @x = rand(SCREEN_W)
    
    @y = 0
    @vy = rand(5)
    @vx = rand(10)+10
    @vx = -@vx if (rand(1) == 1)
    @g = -1
    @w = image.w
    @h = image.h
    @count=0
    @is_dead = false
  end
  
  def center
    cx = @x + (@image.w / 2)
    cy = @y + (@image.h / 2)
    
    [cx, cy]
  end
  
  def act
    @count+=1
    
    
    @vy -= @g
    @y += @vy
    
    @x += @vx
    if @x  < 0
      @x = -@x 
      @vx = -@vx
    end
    
    if @x > SCREEN_W
      @x = SCREEN_W - (@x - SCREEN_W)
      @vx = -@vx
    end
    
    if @y > SCREEN_H
      @y = SCREEN_H - (@y - SCREEN_H)
      @vy *=  -0.99
    end
    
  end
  
  def render(screen)
      screen.put(@image,@x,@y)
  end

  def collides?(chara)
    px, py = chara.center
    distance(@x+@image.w/2, @y+@image.h/2, px, py) < 56
  end

  attr_reader :image
  attr_accessor :x, :y, :state ,:vx ,:vy,:g,:count,:is_dead
end
