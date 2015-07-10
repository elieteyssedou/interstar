require 'gosu'
load 'src/vessel.rb'
load 'src/bullet.rb'
load 'src/rocket.rb'
load 'src/weapon.rb'
load 'src/boom.rb'
load 'src/smoke.rb'
load 'src/worm_hole.rb'
load 'src/asteroid.rb'

WinX = 2560
WinY = 1600
# WinX = 1920
# WinY = 1080

class GameWindow < Gosu::Window
	
	def initialize
    	super WinX, WinY, :fullscreen => true
    	self.caption = "Hart"

		@background = Gosu::Image.new("media/images/background.jpg", :tileable => true)
	
		@bullet_texture = Gosu::Image.new("media/images/bullet.png")
		@bullet_vs_texture = Gosu::Image.new("media/images/bulletvs.png")
		@rocket_texture = Gosu::Image.new("media/images/rocket.png")
		@rocket_vs_texture = Gosu::Image.new("media/images/rocketvs.png")
		@shield_texture = Gosu::Image.new("media/images/bubble.png")
		@heart_texture = Gosu::Image.new("media/images/heart-pixel.png")
		@heart_blue_texture = Gosu::Image.new("media/images/heart-pixel-blue.png")
		
		@font = Gosu::Font.new(30, name: "media/fonts/Minecrafter.Alt.ttf")

		r = rand(1..2)
		if r == 1
			@music = Gosu::Song.new("media/samples/stay.mp3")
		else
			@music = Gosu::Song.new("media/samples/theme.mp3")
 		end
 		@music.play(true)

 		@player = Vessel.new(WinX / 4 * 3, WinY / 4 * 3, 1)
 		@player.warp(WinX / 4 * 3, WinY / 4 * 3)
 		@versus = Vessel.new(WinX / 4, WinY / 4, 2)
 		@versus.warp(WinX / 4, WinY / 4)
 	
 		@acc = @vacc = 0
 	
 		@old = Gosu::milliseconds
		
		@booms = Array.new
		@smokes = Array.new
		@holes = Array.new

		@asteroids = Array.new

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

		@player.recharge
  		@versus.recharge

		@player.move(self.deltatime)
  		@versus.move(self.deltatime)

  		@player.bullarr.each do |b|
  			b.move(self.deltatime)
  			@smokes.push(Smoke.new(b.x, b.y, b.angle, b.who)) if b.life > 0 && b.force == 3 && rand(1..10) == 2
  		end

  		@versus.bullarr.each do |b|
  			b.move(self.deltatime)
  			@smokes.push(Smoke.new(b.x, b.y, b.angle, b.who)) if b.life > 0 && b.force == 3 && rand(1..10) == 2 
  		end

  		@asteroids.each do |a|
  			a.move(self.deltatime)
  		end

  		@old = Gosu::milliseconds

  		@booms.reject! { |boom| boom.die == true }
  		@smokes.reject! { |smoke| smoke.die == true }
		@asteroids.reject! { |asteroid| asteroid.die == true }
  		if @holes[0] && @holes[1]
  			if @holes[0].die == true || @holes[1].die == true
  				@holes = Array.new
  			end
  		end

  		if (rand(1..100) == 66 && @asteroids.size < 2)
  			@asteroids << Asteroid.new
  		end

  		if (rand(1..1000) == 66 && @holes.size == 0)
  			r1 = rand((WinX / 10)..(WinX / 10 * 9))
  			r2 = rand((WinY / 10)..(WinY / 10 * 9))
  			dif = 0
  			while (dif < WinX / 4)
  				r3 = rand((WinX / 10)..(WinX / 10 * 9))
  				dif = r3 - r1
  				dif = dif.abs
  			end
  			r4 = rand((WinY / 10)..(WinY / 10 * 9))
  			dif = 0
  			while (dif < WinY / 4)
  				r4 = rand((WinY / 10)..(WinY / 10 * 9))
  				dif = r4 - r2
  				dif = dif.abs
  			end
  			@holes << WormHole.new(r1, r2, rand(0.0..180.0))
  			@holes << WormHole.new(r3, r4, rand(0.0..180.0))
  		end

  		self.hole_colision
  		self.asteroid_collision

		@player.bullarr.each do |b|
			if b.life > 0 && check_for_collide(@versus, b) == 1
				@player.score += 1 if @versus.life - b.force == 0 && !@versus.shield
				sp = @versus.hit(b.force)
				if (sp == 1)
					b.life = b.life - 1
					@booms.push(Boom.new(b.x, b.y, b.angle, @versus.who))
					Boom.play
				end
			end
		end

		@versus.bullarr.each do |b|
			if b.life > 0 && check_for_collide(@player, b) == 1
				@versus.score += 1 if @player.life - b.force == 0 && !@player.shield
				sp = @player.hit(b.force)
				if (sp == 1)
					b.life = b.life - 1
					@booms.push(Boom.new(b.x, b.y, b.angle, @player.who))
					b.boom
				end
			end
		end

		if check_for_collide(@versus, @player) == 1
			if (@versus.sp == 1 && @player.sp == 1)
			@booms.push(Boom.new(@versus.x, @versus.y, @versus.angle, @versus.who))
			@booms.push(Boom.new(@player.x, @player.y, @player.angle, @player.who))
			@player.boom.play(0.4, 2)
			@player.warp(WinX / 4 * 3, WinY / 4 * 3)
			@versus.warp(WinX / 4, WinY / 4)
			@player.score -= 1 unless @versus.life <= 1
			@versus.score -= 1 unless @player.life <= 1
			end
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

	def hole_colision
			@holes.each_with_index do |wh, i|
  			if (i == 0)
  				a = 1
  			else
  				a = -1
  			end

  			if check_for_w_collide(@player, @holes[i + a]) == 1
  				@player.hole_acc(Gosu::angle(@player.x, @player.y, @holes[i + a].x, @holes[i + a].y))
  			end

  			if check_for_w_collide(@versus, @holes[i + a]) == 1
  				@versus.hole_acc(Gosu::angle(@versus.x, @versus.y, @holes[i + a].x, @holes[i + a].y))
  			end

  			if check_for_h_collide(@player, @holes[i + a]) == 1
  				@player.hole_warp(wh.x, wh.y, wh.angle)
  				wh.play
  			end

  			if check_for_h_collide(@versus, @holes[i + a]) == 1
  				@versus.hole_warp(wh.x, wh.y, wh.angle)
  				wh.play
  			end

  			@asteroids.each do |ast|
  				if check_for_collide(ast, @holes[i + a]) == 1
  					if ast.lst_hole > 3000
  						ret = ast.hole_warp(wh.x, wh.y, wh.angle)
  					else
  						ret = 0
  					end
  					wh.play(0.10, 2) if ret != 0
  				end
  				if check_for_w_collide(ast, @holes[i + a]) == 1
  					ast.hole_acc(Gosu::angle(ast.x, ast.y, @holes[i + a].x, @holes[i + a].y))
  				end
  			end

  			@player.bullarr.each do |b|
				if check_for_w_collide(b, @holes[i + a]) == 1
					b.hole_acc(Gosu::angle(b.x, b.y, @holes[i + a].x, @holes[i + a].y))
				end
			end

			@versus.bullarr.each do |b|
				if check_for_w_collide(b, @holes[i + a]) == 1
					b.hole_acc(Gosu::angle(b.x, b.y, @holes[i + a].x, @holes[i + a].y))
				end
			end


  			@player.bullarr.each do |b|
				if check_for_b_collide(b, @holes[i + a]) == 1
					b.hole_warp(wh.x, wh.y, wh.angle)
				end
			end

			@versus.bullarr.each do |b|
				if check_for_b_collide(b, @holes[i + a]) == 1
					b.hole_warp(wh.x, wh.y, wh.angle)
				end
			end

  		end

	end

	def asteroid_collision
  		@asteroids.each do |a|
  		  	if a.life > 0 && check_for_collide(a, @versus) == 1
  		  		@versus.score -= 1 if @versus.life - a.force == 0 && !@versus.shield
				sp = @versus.hit(a.force, true)
				if (sp == 1)
					a.hit(1, Gosu::angle(a.x, a.y, @player.x, @player.y) )
					@booms.push(Boom.new(a.x, a.y, a.angle, a.who)) if a.life <= 0
					@booms.push(Boom.new(a.x, a.y, a.angle, @versus.who))
					Boom.play
				end
			end
			if a.life > 0 && check_for_collide(a, @player) == 1
  		  		@player.score -= 1 if @player.life - a.force == 0 && !@player.shield
				sp = @player.hit(a.force, true)
				if (sp == 1)
					a.hit(1, Gosu::angle(a.x, a.y, @player.x, @player.y) )
					@booms.push(Boom.new(a.x, a.y, a.angle, a.who)) if a.life <= 0
					@booms.push(Boom.new(a.x, a.y, a.angle, @player.who))
					Boom.play
				elsif (sp == 2)
					a.hit(0, Gosu::angle(a.x, a.y, @player.x, @player.y) )
					@booms.push(Boom.new(a.x, a.y, a.angle, a.who))
					Boom.play
				end
			end
			
			@versus.bullarr.each do |b|
				if b.life > 0 && a.life > 0 && check_for_a_collide(a, b) == 1
					b.life -= 1
					a.hit(b.force, Gosu::angle(a.x, a.y, b.x, b.y) )
					@booms.push(Boom.new(a.x, a.y, a.angle, a.who)) if a.life <= 0
					@booms.push(Boom.new(a.x, a.y, a.angle, @versus.who))
					Boom.play
				end
			end
			@player.bullarr.each do |b|
				if b.life > 0 && a.life > 0 && check_for_a_collide(a, b) == 1
					b.life -= 1
					a.hit(b.force, Gosu::angle(a.x, a.y, b.x, b.y) )
					@booms.push(Boom.new(a.x, a.y, a.angle, a.who)) if a.life <= 0
					@booms.push(Boom.new(a.x, a.y, a.angle, @player.who))
					Boom.play
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
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0x4000ffff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0x40ff00ff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0x40ffff00))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0x40ffffff))
  			Gosu::draw_rect(rand(0.0..WinX), rand(0.0..WinY), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0x40ffffff))
  		end
  		d = 130
  		d2 = 130
  		@holes.each do |h|
  			a = Gosu::distance(@player.x, @player.y, h.x, h.y)
  			d = a if a < d
  		end
		@holes.each do |h|
  			a = Gosu::distance(@versus.x, @versus.y, h.x, h.y)
  			d2 = a if a < d2
  		end

  		if @acc == 0
  			@player.draw(d)
  		else
  			@player.draw_on(d)
  		end

  		if @vacc == 0
  			@versus.draw(d2)
  		else
  			@versus.draw_on(d2)
  		end

  		@player.bullarr.each { |b|  b.draw } 
  		@versus.bullarr.each { |b|  b.draw }
  		@booms.each { |boom| boom.draw }
  		@smokes.each { |smoke| smoke.draw }
  		@holes.each { |hole| hole.draw }
  		@asteroids.each { |asteroid| asteroid.draw}

  		@font.draw("#{@versus.score}", WinX / 7, WinY / 20, 3, 1.0, 1.0, 0xff_9040ff)
  		@font.draw("#{@player.score}", WinX / 7 * 6, WinY / 20, 3, 1.0, 1.0, 0xff_dd2040)

  		# @font.draw("P1 Life : #{@versus.life}", WinX / 7, WinY / 10, 3, 1.0, 1.0, 0xff_00ff00)
  		# @font.draw("P2 Life : #{@player.life}", WinX / 7 * 6, WinY / 10, 3, 1.0, 1.0, 0xff_0000ff)

  		t = 1.0
  		@versus.life.times do
  			@heart_texture.draw(WinX / 7 * t, WinY / 10, 3)
  			t += 0.125
  		end
  		@heart_blue_texture.draw(WinX / 7 * t, WinY / 10, 3) if @versus.shield

  		t = 0.0
  		@player.life.times do
  			@heart_texture.draw(WinX / 7 * (6 + t), WinY / 10, 3)
  			t += 0.125
  		end
  		@heart_blue_texture.draw(WinX / 7 * (6 + t), WinY / 10, 3) if @player.shield

  		t = 1.0
  		@versus.ns.times do
  			@heart_blue_texture.draw(WinX / 7 * t, WinY / 7 * 6, 3)
  			t += 0.125
  		end

  		t = 0.0
  		@player.ns.times do
  			@heart_blue_texture.draw(WinX / 7 * (6 + t), WinY / 7 * 6, 3)
  			t += 0.125
  		end

  		# @font.draw("P1 Shield : #{@versus.ns}", WinX / 7, WinY / 10 * 9, 3, 1.0, 1.0, 0xff_00ff00)
  		# @font.draw("P2 Shield : #{@player.ns}", WinX / 7 * 6, WinY / 10 * 9, 3, 1.0, 1.0, 0xff_0000ff)

  		t = 1.0
  		@versus.bullet.times do
  			@bullet_vs_texture.draw(WinX / 7 * t, WinY / 20 * 19, 3)
  			t += 0.0625
  		end

  		t = 0.0
  		@player.bullet.times do
  			@bullet_texture.draw(WinX / 7 * (6 + t), WinY / 20 * 19, 3)
  			t += 0.0625
  		end

		t = 1.0
  		@versus.rocket.times do
  			@rocket_vs_texture.draw(WinX / 7 * t, WinY / 10 * 9, 3, 0.8, 0.8)
  			t += 0.125
  		end

  		t = 0.0
  		@player.rocket.times do
  			@rocket_texture.draw(WinX / 7 * (6 + t), WinY / 10 * 9, 3, 0.8, 0.8)
  			t += 0.125
  		end
  		# @font.draw("P1 Rocket : #{@versus.rocket}", WinX / 7, WinY / 20 * 19, 3, 1.0, 1.0, 0xff_00ff00)
  		# @font.draw("P2 Rocket : #{@player.rocket}", WinX / 7 * 6, WinY / 20 * 19, 3, 1.0, 1.0, 0xff_0000ff)

  		@font.draw("FPS: #{Gosu::fps}", WinX / 2, WinY / 20 * 19, 3, 1.0, 1.0, 0xff_202020)
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

	def check_for_h_collide(inst1, inst2)
		if inst2.x >= (inst1.x - inst1.width / 4) && inst2.x <= (inst1.x + inst1.width / 4) && inst2.y >= (inst1.y - inst1.height) && inst2.y <= (inst1.y + inst1.height)
			return 1
		end
		return 0
	end

	def check_for_a_collide(inst1, inst2)
		if inst2.x >= (inst1.x - inst1.width / 4) && inst2.x <= (inst1.x + inst1.width / 4) && inst2.y >= (inst1.y - inst1.height / 4) && inst2.y <= (inst1.y + inst1.height / 4)
			return 1
		end
		return 0
	end

	def check_for_w_collide(inst1, inst2)
		if inst2.x >= (inst1.x - inst1.width * 3) && inst2.x <= (inst1.x + inst1.width * 3) && inst2.y >= (inst1.y - inst1.height * 3) && inst2.y <= (inst1.y + inst1.height * 3)
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
				@player.moving = true
			# end
		elsif id == Gosu::KbW
			@vacc = 1
			# if @s.playing?
				@sv = @versus.vroom.play
				@versus.moving = true
			# end
		elsif id == Gosu::KbJ
			@player.shoot(1)
		elsif id == Gosu::KbSpace
			@versus.shoot(1)
		elsif id == Gosu::KbK
			@player.shoot(2)
		elsif id == Gosu::KbV
			@versus.shoot(2)
		elsif id == Gosu::KbH
			@player.bubble
		elsif id == Gosu::KbF
			@versus.bubble
		end
	end

	def button_up(id)
		if id == Gosu::KbUp
			@acc = 0
			@s.stop
			@player.moving = false
		elsif id == Gosu::KbW
			@vacc = 0
			@sv.stop
			@versus.moving = false
		end
	end
end

window = GameWindow.new
window.show