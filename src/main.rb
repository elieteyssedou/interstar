require 'gosu'
load 'src/vessel.rb'
load 'src/bullet.rb'
load 'src/weapon.rb'
load 'src/boom.rb'
load 'src/smoke.rb'

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
		@font = Gosu::Font.new(30)
		@booms = Array.new
		@smokes = Array.new
		# @bg = Gosu::draw_rect(500.0, 500.0, 50.0, 50.0, Gosu::Color.argb(0xff00ffff))
	end

	def update
		if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
			@player.turn_left(self.deltatime)
    	end
		if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
			@player.turn_right(self.deltatime)
		end
		if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
			@player.accelerate
		end

		if Gosu::button_down? Gosu::KbA or Gosu::button_down? Gosu::GpLeft then
			@versus.turn_left(self.deltatime)
    	end
		if Gosu::button_down? Gosu::KbD or Gosu::button_down? Gosu::GpRight then
			@versus.turn_right(self.deltatime)
		end
		if Gosu::button_down? Gosu::KbW or Gosu::button_down? Gosu::GpButton0 then
			@versus.accelerate
		end

		@player.move(self.deltatime)
  		@versus.move(self.deltatime)

  		@player.bullarr.each do |b|
  			b.move(self.deltatime)
  			@smokes.push(Smoke.new(b.x, b.y, b.angle, b.who)) if b.life > 0 && b.force == 2 && rand(1..10) == 2
  		end

  		@versus.bullarr.each do |b|
  			b.move(self.deltatime)
  			@smokes.push(Smoke.new(b.x, b.y, b.angle, b.who)) if b.life > 0 && b.force == 2 && rand(1..10) == 2 
  		end

  		@old = Gosu::milliseconds

  		@booms.reject! { |boom| boom.die == true }
  		@smokes.reject! { |smoke| smoke.die == true }

		@player.bullarr.each do |b|
			if b.life > 0 && check_for_collide(@versus, b) == 1
				@booms.push(Boom.new(@versus.x, @versus.y, @versus.angle, @versus.who))
				Boom.play
				@player.score += 1 if @versus.life - b.force == 0
				@versus.hit(b.force)
				b.life = b.life - 1
			end
		end

		@versus.bullarr.each do |b|
			if b.life > 0 && check_for_collide(@player, b) == 1
				@booms.push(Boom.new(@player.x, @player.y, @player.angle, @player.who))
				b.boom
				@versus.score += 1 if @player.life - b.force == 0
				@player.hit(b.force)
				b.life = b.life - 1
			end
		end

		if check_for_collide(@versus, @player) == 1
			@booms.push(Boom.new(@versus.x, @versus.y, @versus.angle, @versus.who))
			@booms.push(Boom.new(@player.x, @player.y, @player.angle, @player.who))
			@player.boom.play
			@player.warp(WinX / 4 * 3, WinY / 4 * 3)
			@versus.warp(WinX / 4, WinY / 4)
			@player.score += 1 if @versus.life <= 1
			@versus.score += 1 if @player.life <= 1
		end

		@versus.bullarr.each do |b|
			@player.bullarr.each do |b2|
				if b.life > 0 && b2.life > 0 && check_for_b_collide(b, b2) == 1
					@booms.push(Boom.new(b.x, b.y, b.angle, b.who))
					@booms.push(Boom.new(b2.x, b2.y, b2.angle, b2.who))
					b.boom
					b.life = b.life - 1
					b2.life = b2.life - 1
				end
			end
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
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.3..3.0), rand(0.3..3.0), Gosu::Color.argb(0x4000ffff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.3..3.0), rand(0.3..3.0), Gosu::Color.argb(0x40ff00ff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.3..3.0), rand(0.3..3.0), Gosu::Color.argb(0x40ffff00))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.3..3.0), rand(0.3..3.0), Gosu::Color.argb(0x40ffffff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.3..3.0), rand(0.3..3.0), Gosu::Color.argb(0x40ffffff))
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
  		@smokes.each { |smoke| smoke.draw}

  		@font.draw("P1 Score: #{@versus.score}", WinX / 7, WinY / 20, 3, 1.0, 1.0, 0xff_00ff00)
  		@font.draw("P2 Score: #{@player.score}", WinX / 7 * 6, WinY / 20, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("P1 Life : #{@versus.life}", WinX / 7, WinY / 10, 3, 1.0, 1.0, 0xff_00ff00)
  		@font.draw("P2 Life : #{@player.life}", WinX / 7 * 6, WinY / 10, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("P1 Shield : #{@versus.ns}", WinX / 7, WinY / 10 * 9, 3, 1.0, 1.0, 0xff_00ff00)
  		@font.draw("P2 Shield : #{@player.ns}", WinX / 7 * 6, WinY / 10 * 9, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("P1 Rocket : #{@versus.rocket}", WinX / 7, WinY / 20 * 19, 3, 1.0, 1.0, 0xff_00ff00)
  		@font.draw("P2 Rocket : #{@player.rocket}", WinX / 7 * 6, WinY / 20 * 19, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("FPS: #{Gosu::fps}", WinX / 2, WinY / 20 * 19, 3, 1.0, 1.0, 0xff_ff0000)
	end

	def check_for_collide(inst1, inst2)
		if inst2.x >= (inst1.x - inst1.width / 2) && inst2.x <= (inst1.x + inst1.width / 2) && inst2.y >= (inst1.y - inst1.height / 2) && inst2.y <= (inst1.y + inst1.height / 2)
			return 1
		end
		return 0
	end

	def check_for_b_collide(inst1, inst2)
		if inst2.x >= (inst1.x - inst1.width) && inst2.x <= (inst1.x + inst1.width) && inst2.y >= (inst1.y - inst1.height) && inst2.y <= (inst1.y + inst1.height)
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
				@sv = @player.vroom.play
			# end
		elsif id == Gosu::KbN
			@player.shoot(1)
		elsif id == Gosu::KbSpace
			@versus.shoot(1)
		elsif id == Gosu::KbK
			@player.shoot(2)
		elsif id == Gosu::KbV
			@versus.shoot(2)
		elsif id == Gosu::KbF
			@player.bubble
		elsif id == Gosu::KbJ
			@versus.bubble
		end
	end

	def button_up(id)
		if id == Gosu::KbUp
			@acc = 0
			@s.stop
		elsif id == Gosu::KbW
			@vacc = 0
			@sv.stop
		end
	end
end

window = GameWindow.new
window.show