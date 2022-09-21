require 'gosu'

class Player
    attr_reader :x, :y, :angle

    def initialize(window)
        @x = 400
        @y = 550
        @v_x = @v_y = @angle = 0
        @spaceship = Gosu::Image.new('Media/Image_X-wing.png')
    end

    def turn_right
        @angle += 3 if (@angle <= 40)
    end

    def turn_left
        @angle -= 3 if (@angle >= -40)
    end

    def accelerate
        @v_x += Gosu.offset_x(@angle, 0.5)
        @v_y += Gosu.offset_y(@angle, 0.5)
    end

    def decelerate
        @v_x -= Gosu.offset_x(@angle, 0.5)
        @v_y -= Gosu.offset_y(@angle, 0.5)
    end

    def move
        @x += @v_x
        @y += @v_y
        @v_x *= 0.9
        @v_y *= 0.9
        if (@x > 783)
            @v_x = 0
            @x = 783
        elsif (@x < 17)
            @v_x = 0
            @x = 17
        end
        if (@y > 575)
            @v_y = 0
            @y = 575
        elsif (@y < 25)
            @v_y = 0
            @y = 25
        end
    end

    def draw
        @spaceship.draw_rot(@x, @y, 0, @angle)
    end
end

class Bullet
    attr_reader :x, :y

    def initialize(window, x, y, angle)
        @x = x
        @y = y
        @angle = angle
        @bullet = Gosu::Image.new('Media/Image_Plasma_Bullet.png')
    end

    def move
        @x += Gosu.offset_x(@angle, 10)
        @y += Gosu.offset_y(@angle, 10)
    end

    def draw
        @bullet.draw_rot(@x, @y, 0, @angle)
    end
end

class Enemy
    attr_reader :x, :y
    
    def initialize(window)
        @x = rand (20-780)
        @y = 20
        @enemy = Gosu::Image.new('Media/Image_TIE.png')
    end

    def move
        @y += 2
    end

    def draw
        @enemy.draw_rot(@x, @y, 0)
    end
end

class Heart
    attr_reader :x, :y
    
    def initialize(window)
        @x = rand (25-775)
        @y = 25
        @heart = Gosu::Image.new('Media/Image_Heart.png')
    end

    def move
        @y += 5
    end

    def draw
        @heart.draw_rot(@x, @y, 0)
    end
end

class Explosion
    attr_reader :j

    def initialize(window, x, y)
        @x = x
        @y = y
        @explosions = Gosu::Image.load_tiles('Media/Image_Explosions.png', 40, 40)
        @i = 0
        @j = false
    end

    def draw
        if (@i < @explosions.count)
            @explosions[@i].draw_rot(@x, @y, 0)
            @i += 1
        else
            @j = true
        end
    end
end

class StarWars < Gosu::Window
    def initialize
        super(800, 600)
        self.caption = 'Star Wars'
        @question = Gosu::Image.new('Media/Image_Question.png')
        @space_0 = Gosu::Image.new('Media/Image_Space_0.jpg')
        @space_1 = Gosu::Image.new('Media/Image_Space_1.jpg')
        @space_2 = Gosu::Image.new('Media/Image_Space_2.jpg')
        @spaceship = Gosu::Image.new('Media/Image_X-wing.png')
        @enemy = Gosu::Image.new('Media/Image_TIE.png')
        @heart_0 = Gosu::Image.new('Media/Image_Heart.png')
        @great_enemy = Gosu::Image.new('Media/Image_Star_Destroyer.png')
        @large_explosions = Gosu::Image.load_tiles('Media/Image_Large_Explosions.png', 200, 200)
        @start_music = Gosu::Song.new('Media/Song_Star_Wars_Main_Theme.wav')
        @instruction_music = Gosu::Song.new('Media/Song_Star_Wars_Ancient_Sith_Theme.wav')
        @game_music = Gosu::Song.new('Media/Song_Star_Wars_Battle_of_The_Heroes.wav')
        @last_music = Gosu::Song.new('Media/Song_Star_Wars_The_Empire_Theme.ogg')
        @end_music = Gosu::Song.new('Media/Song_Star_Wars_Light_of_the_Force.wav')
        @shooting_sound = Gosu::Sample.new('Media/Sound_Laser_Shoot.wav')
        @small_explosion_sound = Gosu::Sample.new('Media/Sound_Small_Explosion.wav')
        @large_explosion_sound = Gosu::Sample.new('Media/Sound_Large_Explosion.wav')
        @collect_sound = Gosu::Sample.new('Media/Sound_Collecting.wav')
        @y = 43
        @player = Player.new(self)
        @font = Gosu::Font.new(30)
        @bullets = []
        @enemies = []
        @explosions = []
        @hearts = []
        @score = @start_time = @i = @j = @k = 0
        @life = 5
        @play = 0
    end

    def button_down(id)
        if (@play == 1)
            if (id == Gosu::KbZ)
                @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)             
                @shooting_sound.play(0.3)
            end
        elsif (@play == 2) || (@play == -1)
            if (id == Gosu::KbSpace)
                @play = 1
                @i = @j = @k = @score = 0
                @start_time = Gosu.milliseconds
                @life = 5
                @y = 43
            end
        elsif (@play == 0)
            if (id == Gosu::KbSpace)
                @play = 1
                @i = @j = @k = @score = 0
                @start_time = Gosu.milliseconds
                @life = 5
                @y = 43
            elsif (id == Gosu::MsRight)
                @play = -1
            end
        end
        if (id == Gosu::KbK) && (@play != 0)
            @play = 0
        elsif (id == Gosu::KbEscape)
            close
            Menu.new.show
        end
    end

    def update
        if (@play == 1)
            @player.turn_right if button_down?(Gosu::KbRight) or button_down?(Gosu::KbD)
            @player.turn_left if button_down?(Gosu::KbLeft) or button_down?(Gosu::KbA)
            @player.accelerate if button_down?(Gosu::KbUp) or button_down?(Gosu::KbW)
            @player.decelerate if button_down?(Gosu::KbDown) or button_down?(Gosu::KbS)
            @player.move
            @bullets.each do |bullet|
                bullet.move
            end
            @enemies.push Enemy.new(self) if (rand < 0.04) && (@enemies.size < 5)
            @enemies.each do |enemy|
                enemy.move
            end
            @hearts.push Heart.new(self) if rand(1-5000) <= 2
            @hearts.each do |heart|
                heart.move
            end
            @enemies.dup.each do |enemy|
                @bullets.dup.each do |bullet|
                    if (Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y) < 24)
                        @enemies.delete enemy
                        @bullets.delete bullet
                        @explosions.push Explosion.new(self, enemy.x, enemy.y)
                        @score += 3
                        @small_explosion_sound.play(0.7)
                    end
                end
                if (Gosu.distance(enemy.x, enemy.y, @player.x, @player.y) < 40)
                    @enemies.delete enemy
                    @explosions.push Explosion.new(self, enemy.x, enemy.y)
                    @life -= 1
                    @score -= 1
                    @small_explosion_sound.play(0.7)
                end
            end
            @hearts.dup.each do |heart|
                if (Gosu.distance(@player.x, @player.y, heart.x, heart.y) < 48)
                    @life += 1
                    @hearts.delete heart
                    @collect_sound.play
                end
            end
            @explosions.dup.each do |explosion|
                @explosions.delete explosion if (explosion.j)
            end
            @play = 2 if @life <= 0
            @enemies.dup.each do |enemy|
                @enemies.delete enemy if (enemy.y > 600)
            end
            @bullets.dup.each do |bullet|
                @bullets.delete bullet if (bullet.x > 800) || (bullet.x < 0) || (bullet.y < 0)
            end
            @time = (30 - ((Gosu.milliseconds - @start_time) / 1000)).to_i
            if (@time <= 10)
                @y += 1
                if (Gosu.distance(@player.x, @player.y, 400, @y) < 100)
                    @life -= 4
                    @large_explosion_sound.play
                end
                @bullets.dup.each do |bullet|
                    if ((Gosu.distance(bullet.x, bullet.y, 400, @y) < 50) && (@i < 20))   
                        @bullets.delete bullet
                        @i += 1
                    end
                end
            end
        end
    end

    def draw
        if (@play == 0)
            @start_music.play(true)
            @space_0.draw(0, 0, 0)
            @font.draw('Welcome to ', 60, 100, 0, 2.0, 2.0, Gosu::Color::AQUA)
            @font.draw('STAR WARS', 370, 90, 0, 2.4, 2.4, Gosu::Color::YELLOW)
            @font.draw('(By BLOOD MOON)', 245, 210, 0, 1.4, 1.4, Gosu::Color::RED)
            @font.draw('Right-click for Instruction or', 255, 385, 0, 0.9, 0.9, Gosu::Color::GREEN)
            @font.draw('Press Space bar to begin...', 257, 430, 0, 0.9, 0.9, Gosu::Color::GREEN)
        elsif (@play == -1)
            @instruction_music.play(true)
            @question.draw(0, 0, 0)
            @font.draw('-> The game lasts for 30 seconds. You will have 5 lives. Earn 80 scores to win.', 20, 270, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('-> Move Your ship              with the Left, Right, Up and Down arrow keys (or A, D, W, S keys respectively).', 20, 300, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @spaceship.draw(140, 285, 0, 0.7, 0.7)
            @font.draw('-> Shoot Enemy ships           by pressing the Z key and earn 3 score for each.', 20, 330, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('If your ship crashes into an enemy, your will lose 1 life. When your life is 0, you will lose the game.', 20, 360, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @enemy.draw(160, 325, 0, 0.7, 0.7)
            @font.draw('-> In the last 10 seconds, the enemmy mother ship                 will be deployed.', 20, 390, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('Shoot it 20 times to earn 15 scores. Be careful, if your ship crashed into the mother ship, it will lose 4 lives.', 20, 420, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('-> You will get an extra life if your ship gets one          from space.', 20, 450, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('-> At any time, press K key to return to the Star wars Menu, or Esc to the Main Menu.', 20, 480, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('-> Good luck !!!', 20, 510, 0, 0.5, 0.5, Gosu::Color::GRAY)
            @font.draw('Press Space bar to begin...', 257, 530, 0, 0.9, 0.9, Gosu::Color::WHITE)
            @heart_0.draw(310, 446, 0, 0.5, 0.5)
            @great_enemy.draw(330, 388, 0, 0.2, 0.2)
        elsif (@play == 1)
            if (@time >= 12)
                @game_music.play(true)
            else
                @last_music.play(true) 
            end
            @space_1.draw(0, 0, 0)
            @player.draw
            @bullets.each do |bullet|
                bullet.draw
            end
            @enemies.each do |enemy|
                enemy.draw
            end
            @hearts.each do |heart|
                heart.draw
            end
            @explosions.each do |explosion|
                explosion.draw
            end
            @font.draw('Your score: ' + @score.to_s + '/80', 20, 20, 0, 1.0, 1.0, Gosu::Color::WHITE)
            @font.draw(@life.to_s + 'x', 680, 15, 0, 1.5, 1.5, Gosu::Color::RED)
            @heart_0.draw(740, 12, 0)
            if (@time > 10)
                @font.draw('Remaining time: ' + @time.to_s, 20, 560, 0, 1.0, 1.0, Gosu::Color::FUCHSIA)
            else
                if (rand(1-100) < 30) && ((Gosu.milliseconds - @start_time) / 1000 >= 20)
                    @font.draw('Remaining time: ' + @time.to_s, 20, 560, 0, 1.0, 1.0, Gosu::Color::FUCHSIA)
                elsif ((Gosu.milliseconds - @start_time) / 1000 > 30)
                    @play = 2
                end
            end
            if (@time <= 10)
                @great_enemy.draw_rot(400, @y, 0) if (@i < 20) && (@k == 0)
                if (@i == 20) && (@k == 0)
                    if (@j < @large_explosions.count)
                        @large_explosions[@j].draw_rot(400, @y, 0)
                        @j += 1
                    end
                    @large_explosion_sound.play
                    @score += 15
                    @k = 1
                end
            end
            @play = 2 if (@score >= 80)    
        elsif (@play == 2)
            @enemies.dup.each do |enemy|
                @enemies.delete enemy
            end
            @bullets.dup.each do |bullet|
                @bullets.delete bullet
            end
            @explosions.each do |explosion|
                @explosions.delete explosion
            end
            @end_music.play(true)
            @space_2.draw(0, 0, 0)
            @font.draw('GAME OVER', 250, 100, 0, 1.8, 1.8, Gosu::Color::WHITE)
            if (@score >= 80)
                @font.draw('Congratulation, your score is ' + @score.to_s  + '! ', 220, 470, 0, 1.0, 1.0, Gosu::Color::GREEN)
                @font.draw('Press Space bar to play again.'.to_s, 225, 530, 0, 1.0, 1.0, Gosu::Color::BLUE)
            elsif (@life <= 0)
                @font.draw('Oops!! Your ship is destroyed, your score is ' + @score.to_s, 120, 470, 0, 1.0, 1.0, Gosu::Color::GREEN)
                @font.draw('Press Space bar to try again :D'.to_s, 215, 530, 0, 1.0, 1.0, Gosu::Color::BLUE)
            else
                @font.draw('Time out, your score is ' + @score.to_s, 250, 470, 0, 1.0, 1.0, Gosu::Color::GREEN)
                @font.draw('Press Space bar to try again :D'.to_s, 215, 530, 0, 1.0, 1.0, Gosu::Color::BLUE)
            end
        end
    end
end

