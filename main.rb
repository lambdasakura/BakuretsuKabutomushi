# -*- coding: utf-8 -*-
##########################################################################
#
# Shooting game like Bakuretu Kabutomushi(like SuperMarioRPG's minigame)
# 
# Author: lambda_sakura(lambda.sakura@gmail.com)
# 
###########################################################################

require "sdl"
require_relative "./src/lib/fpstimer"
require_relative "./src/lib/input"
require_relative "./src/player"
require_relative "./src/chara"
require_relative "./src/enemy"


def load_image(fname)
  image = SDL::Surface.load(fname)
  image.set_color_key(SDL::SRCCOLORKEY, [255, 255, 255])

  image
end



SCREEN_W = 640
SCREEN_H = 480
HOLIZON = 450

#
# SaveData class
#
# for manipulate game's score.
# 
class SaveData

  attr_accessor :high_score
  
  def initialize(file_name="savefile.dat")
    @high_score = load_score(file_name)
  end

  # load hi score from file
  def load_score(file_name)
    if File.exist?(file_name)
      # hi score data written in  Marshial format
      File.open(file_name, "rb"){|f| Marshal.load(f) } 
    else
      # if score file not exist.
      # hi score is 0
      0
    end
  end

  # write hi score to file in Marshial format
  def save
    File.open("savefile.dat", "wb"){|f| Marshal.dump(@high_score, f) }
  end

end


#
# 入力の初期化
# 
class Input
  define_key SDL::Key::ESCAPE, :exit
  define_key SDL::Key::LEFT, :left
  define_key SDL::Key::RIGHT, :right
  define_key SDL::Key::SPACE, :space 
  define_key SDL::Key::RETURN, :ok
  define_pad_button 1, :space
  define_pad_button 2, :ok
end


class TitleScene
  def initialize 
#    @title_image = SDL::Surface.load("image/title.png")
    @back = SDL::Surface.load("resource/image/back.jpg")
    @font = SDL::TTF.open('resource/font/cinecaption226.ttf', 24)    
  end
  
  def start
    
  end
  
  def act(input)
    if input.ok || input.space
      return :game
    else
      return nil
    end
  end

  def render(screen)
    screen.put(@back,0,0)
    @font.draw_solid_utf8(screen, 'きたーーーーーーーーーー', 100, 100, 255, 255, 255)
  end
end

class GameScene
  attr_reader :high_score  # @high_score へのアクセサを定義
  attr_accessor :score
  
  def initialize(highscore)
    @high_score = highscore

    if highscore == nil
      @high_score = 0
    end

    @back = SDL::Surface.load("resource/image/back.jpg")
    @font = SDL::TTF.open('resource/font/cinecaption226.ttf', 24)    

#    @bgm = SDL::Mixer::Music.load("sound/famipop3.it")
    @bgm = SDL::Mixer::Music.load("resource/sound/bgm.ogg")
  end

  def start
    @charas = Characters.new
    @player = Player.new(240)
    @score = 0

    SDL::Mixer.play_music(@bgm,-1)

  end

  def act(input)


    @charas.act(@player)
    @player.act(input,@charas)

    @score = @charas.score
    if @player.state == "dead"
      SDL::Mixer.halt_music
      return :game_over
    else
      nil
    end

  end

  def render(screen)
    #背景の描画
    screen.put(@back,0,0)
    
    #キャラクターの描画
    @player.render(screen)
    @charas.render(screen)
    
    if @score > @high_score 
      @high_score = @score
    end
    
    @font.draw_solid_utf8(screen, "score:#{@score}", 0, 0, 255, 255, 255)    
    @font.draw_solid_utf8(screen, "highscore:#{@high_score}", 0, 30, 255, 255, 255)    
  end

  attr_accessor :score

end

class GameOverScene
  def initialize
    @back = SDL::Surface.load("resource/image/back.jpg")
    @font = SDL::TTF.open('resource/font/cinecaption226.ttf', 24)    
  end
  def start
    @time = 0
  end

  def act(input)
    @time += 1
    
    if @time > 120
      return :title
    else
      return nil
    end
  end

  def render(screen)
    screen.put(@back,0,0)
    @font.draw_solid_utf8(screen, 'gameover', 0, 0, 255, 255, 255)
  end
end

#SDLの初期化
SDL.init(SDL::INIT_EVERYTHING)
SDL::TTF.init
SDL::Mixer.open(22050*2,SDL::Mixer::DEFAULT_FORMAT,2,1024)

#画面の初期化
screen = SDL.set_video_mode(SCREEN_W,SCREEN_H,24,SDL::HWSURFACE)
# screen = SDL.set_video_mode(SCREEN_W,SCREEN_H,0,SDL::DOUBLEBUF |SDL::HWSURFACE|SDL::FULLSCREEN)
SDL::Mouse.hide() #マウスの表示はしない

#タイマーの用意
timer = FPSTimerLight.new
timer.reset

#入力処理の初期化
input = Input.new

save_data = SaveData.new() #セーブデータの読み込み

Scenes = {
  :title => TitleScene.new,
  :game => GameScene.new(save_data.high_score),
  :game_over => GameOverScene.new,
}

scene = Scenes[:title]

loop do
  input.poll
  break if input.exit

  next_scene = scene.act(input)
  
  if next_scene
    save_data.high_score = Scenes[:game].high_score
    save_data.save

    scene = Scenes[next_scene]
    scene.start
  end

  scene.render(screen)

  #タイマー処理
  timer.wait_frame do
    screen.update_rect(0,0,0,0)
  end
end

