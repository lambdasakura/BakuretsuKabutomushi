# -*- coding: utf-8 -*-
class Character

  def distance(x1, y1, x2, y2)
    Math.sqrt((x1-x2)**2 + (y1-y2)**2)  # n**2 は 「n の 2 乗」(=n*n)
  end
end

class Heart < Character
  def initialize
    @image = load_image("resource/image/heart.png")
    @x = rand(640)
    @y = 0
    @is_dead = false
  end

  def act
    @y +=10
    @y = 450 if @y > 450
  end

  def render(screen)
    screen.put(@image,@x,@y)
  end

 def collides?(chara)
   px, py = chara.center
   distance(@x+@image.w/2, @y+@image.h/2, px, py) < 50
 end


  attr_accessor :is_dead

end


class Score < Character
  def initialize(x,y,score)
    @x = x
    @y = y
    @score = score

    @timer = 0
    @is_dead = false
    @font = SDL::TTF.open('resource/font/cinecaption226.ttf', 12)    
  end
  
  def act
    @timer += 1
    @is_dead = true if @timer > 120

  end
  
  def render(screen)
    @font.draw_solid_utf8(screen, @score.to_s, @x, @y, 255, 255, 255)
  end

  attr_reader :is_dead

end

class Tama < Character
  
  def initialize(x)
    @image = load_image("resource/image/tama.png")
    @x = x
    @y = SCREEN_H - @image.h
    @vy = 10
    @w = image.w
    @h = image.h
  end
  
  def collides?(chara)
    px, py = chara.center
    distance(@x+@image.w/2, @y+@image.h/2, px, py) < 40
  end
  
  
  def act()
    if @vy < 0
      @vy =0
    end
    
    @y -= @vy
    @is_dead = true if @y < 0
  end
  
  attr_reader :vy, :image
  attr_accessor :x, :y, :is_dead
  
end

class MiniTama < Character
  
  def initialize(x,y,counter)
    @image = load_image("resource/image/hosi.png")
    @vx = rand(4) +5
    @vy = rand(4) + 5
    @vx = -@vx if (rand(2) == 1)
    @vy = -@vy if (rand(2) == 1)
    @x = x
    @y = y
    @count = 0
    @is_dead = false
    @counter = counter
  end
  
  
  def act()
    @count += 1
    @x += @vx
    @y += @vy
    
    @is_dead = true if @y < 0
    @is_dead = true if @x < 0
    @is_dead = true if (@count > 20)
    
  end
  
  def render(screen)
    screen.put(@image,@x,@y)
  end
  
  def collides?(chara)
    px, py = chara.center
    distance(@x+@image.w/2, @y+@image.h/2, px, py) < 50
  end
  
  attr_reader :vy, :image , :counter
  attr_accessor :x, :y, :is_dead
  
  
end



class Characters
  def initialize
    @tamas = []
    @enemys = []
    @minitamas = []
    @scores = []
    @hearts = []
    
    @score = 0
    @font = SDL::TTF.open('resource/font/cinecaption226.ttf', 8)    
    
    @sound_get  = SDL::Mixer::Wave.load("resource/sound/get.wav")
    @sound_bomb = SDL::Mixer::Wave.load("resource/sound/bom08.wav")
    
    @enemy_counter=1
    
    @HEARTS_RATE=50
    @counter = 0
  end
  
  def heart_add
    @hearts << Heart.new
  end
  
  
  def enemy_add
    @enemys << Enemy.new
  end
  def tama_add(x)
    @tamas << Tama.new(x)
  end
  
  def score_add(x,y,score)
    @scores << Score.new(x,y,score)
  end
  
  def minitama_add(x,y,counter)
    @minitamas << MiniTama.new(x,y,counter)
  end
  
  
  
  def act(player)
    @counter += 1
    @scores.each do |score|
      score.act
    end
    
    @hearts.each do |heart|
      heart.act
    end
    
    @tamas.each do |tama|
      tama.act
    end
    
    #敵を適当に生成
    #後で生成方法は変える
=begin
    rate = 0
    case @counter
    when 1..599
      rate  = 120
    when 600..1200
      rate = 60
=end      
    enemy_add if rand(10) == 1
    @enemys.each do |enemy|
      enemy.act
    end
    
    @minitamas.each do |minitama|
      minitama.act
    end
    
    
    #当たり判定
    @minitamas.each do |tama|
      @enemys.each do |enemy|
        if enemy.is_dead == false
          if tama.collides?(enemy)

            enemy.is_dead = true
            tama.is_dead = true
            
            @enemy_counter+=1
            heart_add if( @enemy_counter % @HEARTS_RATE ) == 0
            SDL::Mixer.play_channel(0, @sound_get, 0) 
            
            @score += (tama.counter+1)**2 * 1000 
            score_add(enemy.x,enemy.y,(tama.counter+1)**2 * 1000)
            
            5.times do
              minitama_add(enemy.x,enemy.y,tama.counter+1)
            end
            
          end
        end
      end
    end
    
    
    
    #弾と敵のあたり判定
    @tamas.each do |tama|
      @enemys.each do |enemy|
        if enemy.is_dead == false
          if tama.collides?(enemy)
            
            heart_add if( @enemy_counter % @HEARTS_RATE ) == 0
            enemy.is_dead = true
            tama.is_dead = true
            SDL::Mixer.play_channel(0, @sound_get, 0) 
            @score += 1000
            score_add(enemy.x,enemy.y,1000)
            @enemy_counter += 1
            5.times do
              minitama_add(enemy.x,enemy.y,0)
            end
          end
        end
      end
    end
  
      #プレイヤと敵のあたり判定
    if player.state == "alive"
      @enemys.each do | enemy|
        if enemy.collides?(player)
          SDL::Mixer.play_channel(1, @sound_bomb, 0)  
          player.state = "damaged"
        end
      end
    end
    
    if player.state == "alive" || player.state == "muteki"
      @hearts.each do |heart|
        if heart.collides?(player)
          SDL::Mixer.play_channel(1,@sound_get,0)
          player.timer -= 300
          heart.is_dead = true
        end
      end
    end
    
    @enemys.each do |enemy|
      if enemy.is_dead == false
        if enemy.count > 600
          enemy.is_dead = true
          5.times do
            minitama_add(enemy.x,enemy.y,0)
          end
        end
      end
    end
    
    
    if player.state == "dying"
      5.times do
        minitama_add(player.x,player.y,0)
      end
      player.state = "dying2"
    end

    if player.state == "dying2"
      
      if (@tamas.size == 0) && ( @minitamas.size == 0)
        player.state = "dead"
      end
    end
      
  
      @tamas.reject!{|tama| tama.is_dead}
      @minitamas.reject!{|minitama| minitama.is_dead}
      
      @scores.reject!{|score| score.is_dead}
      @hearts.reject!{|heart| heart.is_dead}
      
      @enemys.reject!{|enemy| enemy.is_dead}
      #    puts @score
    end
    
    
    def render(screen)
      @tamas.each do |tama|
        screen.put(tama.image,tama.x,tama.y)
      end
      
      @enemys.each do |enemy|
        enemy.render(screen)
      end
      
      @minitamas.each do |minitama|
        minitama.render(screen)
      end
      
      
      @scores.each do |score|
        score.render(screen)
      end
      
      @hearts.each do |heart|
        heart.render(screen)
      end
      
    end
    
    attr_accessor :score
  end
