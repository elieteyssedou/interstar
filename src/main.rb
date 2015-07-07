require 'gosu'
load 'src/vessel.rb'
load 'src/bullet.rb'
load 'src/weapon.rb'
load 'src/boom.rb'

WinX = 1920
WinY = 1080

class GameWindow < Gosu::Window
	def initialize
    	super WinX, WinY, :fullscreen => true
    	self.caption = "Hart"

		@background = Gosu::Image.new("media/images/background.jpg", :tileable => true)
		@music = Gosu::Song.new("media/samples/theme.mp3")
 		@player = Vessel.new(WinX / 4 * 3, WinY / 4 * 3, 1)
 		@player.warp(WinX / 4 * 3, WinY / 4 * 3)
 		@versus = Vessel.new(WinX / 4, WinY / 4, 2)
 		@versus.warp(WinX / 4, WinY / 4)
 		# @s = @player.vroom.play
 		# @s.stop
 		@acc = @vacc = 0
 		@music.play(true)
 		@old = Gosu::milliseconds
		@font = Gosu::Font.new(40)
		@booms = Array.new
		# @bg = Gosu::draw_rect(500.0, 500.0, 50.0, 50.0, Gosu::Color.argb(0xff00ffff))
	end

	def update
		if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
			@player.turn_left
    	end
		if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
			@player.turn_right
		end
		if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
			@player.accelerate
		end

		if Gosu::button_down? Gosu::KbA or Gosu::button_down? Gosu::GpLeft then
			@versus.turn_left
    	end
		if Gosu::button_down? Gosu::KbD or Gosu::button_down? Gosu::GpRight then
			@versus.turn_right
		end
		if Gosu::button_down? Gosu::KbW or Gosu::button_down? Gosu::GpButton0 then
			@versus.accelerate
		end

		@player.move(self.deltatime)
  		@versus.move(self.deltatime)

  		@player.bullarr.each { |b| b.move(self.deltatime)}
  		@versus.bullarr.each { |b| b.move(self.deltatime)}

  		@old = Gosu::milliseconds

  		@booms.reject! { |boom| boom.die == true }

		@player.bullarr.each do |b|
			if b.life > 0 && check_for_collide(@versus, b) == 1
				@booms.push(Boom.new(@versus.x, @versus.y, @versus.angle, @versus.who))
				Boom.play
				@player.score += 1 if @versus.life <= 1
				@versus.hit
				b.life = b.life - 1
			end
		end

		@versus.bullarr.each do |b|
			if b.life > 0 && check_for_collide(@player, b) == 1
				@booms.push(Boom.new(@player.x, @player.y, @player.angle, @player.who))
				Boom.play
				@versus.score += 1 if @player.life <= 1
				@player.hit
				b.life = b.life - 1
			end
		end

		if check_for_collide(@versus, @player) == 1
			@booms.push(Boom.new(@versus.x, @versus.y, @versus.angle, @versus.who))
			@booms.push(Boom.new(@player.x, @player.y, @player.angle, @player.who))
			Boom.play
			@player.warp(WinX / 4 * 3, WinY / 4 * 3)
			@versus.warp(WinX / 4, WinY / 4)
			@player.score += 1 if @versus.life <= 1
			@versus.score += 1 if @player.life <= 1
		end
	end

	def draw
  		# x = y = 0
  		# while (y < WinY)
  		# 	x = 0
  		# 	while (x < WinX)
  		# 		@background.draw(x, y, 0)
  		# 		x += @background.width
  		# 	end
  		# 	y += @background.height
  		# end
  		# @bg.draw
  		100.times do
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.2..3.0), rand(0.2..3.0), Gosu::Color.argb(0x4000ffff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.2..3.0), rand(0.2..3.0), Gosu::Color.argb(0x40ff00ff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.2..3.0), rand(0.2..3.0), Gosu::Color.argb(0x40ffff00))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.2..3.0), rand(0.2..3.0), Gosu::Color.argb(0x40ffffff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.2..3.0), rand(0.2..3.0), Gosu::Color.argb(0x40ffffff))
  		end
  		if @acc == 0
  			@player.draw
  		else
  			@player.draw_on
  		end

  		if @vacc == 0
  			@versus.draw
  		else
  			@versus.draw_on
  		end

  		@player.bullarr.each { |b|  b.draw } 
  		@versus.bullarr.each { |b|  b.draw }
  		@booms.each { |boom| boom.draw}

  		@font.draw("Player 1 : #{@versus.score}", WinX / 7, WinY / 20, 3, 1.0, 1.0, 0xff_00ff00)
  		@font.draw("Player 2 : #{@player.score}", WinX / 7 * 6, WinY / 20, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("Player 1 life : #{@versus.life}", WinX / 7, WinY / 10, 3, 1.0, 1.0, 0xff_00ff00)
  		@font.draw("Player 2 life : #{@player.life}", WinX / 7 * 6, WinY / 10, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("FPS: #{Gosu::fps}", WinX / 7 * 6, WinY / 10 * 9, 3, 1.0, 1.0, 0xff_ff0000)
	end

	def check_for_collide(inst1, inst2)
		if inst2.x >= (inst1.x - inst1.width / 2) && inst2.x <= (inst1.x + inst1.width / 2) && inst2.y >= (inst1.y - inst1.height / 2) && inst2.y <= (inst1.y + inst1.height / 2)
			return 1
		end
		return 0
	end

	def deltatime
  		Gosu::milliseconds - @old
	end

	def button_down(id)
		if id == Gosu::KbEscape
			close
		elsif id == Gosu::KbUp
			@acc = 1
			# if @s.playing?
				@s = @player.vroom.play
			# end
		elsif id == Gosu::KbW
			@vacc = 1
			# if @s.playing?
				@s = @player.vroom.play
			# end
		elsif id == 231
			@player.shoot
		elsif id == 227
			@versus.shoot
		end
	end

	def button_up(id)
		if id == Gosu::KbUp
			@acc = 0
			@s.stop
		elsif id == Gosu::KbW
			@vacc = 0
			@s.stop
		end
	end
end

window = GameWindow.new
window.show