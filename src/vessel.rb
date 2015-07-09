class Vessel
	attr_reader :angle, :bullarr, :width, :height, :x, :y, :who, :vroom, :rocket, :bullet, :boom, :ns, :shield
	attr_accessor :score, :moving


	def initialize(defx, defy, who = 0)
		@who = who
		if (who == 1)
			@skin = Gosu::Image.new("media/images/vessel.png")
			@skin_on = Gosu::Image.new("media/images/vessel-on.png")
		elsif who == 2
			@skin = Gosu::Image.new("media/images/vesselvs.png")
			@skin_on = Gosu::Image.new("media/images/vesselvs-on.png")
		end
		@vroom = Gosu::Sample.new("media/samples/starship.wav")
		@boom = Gosu::Sample.new("media/samples/crash.wav")
		@x = @y = @vx = @vy = @angle = 0.0
		@bullarr = Array.new
		@width = @skin.width
		@height = @skin.height
		@score = 0
		@defx = defx
		@defy = defy
		@lsthole = Gosu::milliseconds
		@moving = false
	end

	def warp(x, y)
		@lst = Gosu::milliseconds
		@lst_r = Gosu::milliseconds
		@shield = Bubble.new(@who)
		@ns = 1
		@rocket = 3
		@bullet = 10
		@x = x
		@y = y
		@life = 3
	end

	def hole_warp(x, y, angle)
		if (Gosu::milliseconds - @lsthole > 1000)
			@angle = angle + 90
			@x = x + Gosu::offset_x(@angle, 10)
			@y = y + Gosu::offset_y(@angle, 10)
			@vx = Gosu::offset_x(@angle, @vx) + Gosu::offset_x(@angle, 20)
			@vy = Gosu::offset_y(@angle, @vy) + Gosu::offset_y(@angle, 20)
			@lsthole = Gosu::milliseconds
		end
		# @life = 3
	end

	def hole_acc(angle)
		@vx += Gosu::offset_x(angle, 0.2)
		@vy += Gosu::offset_y(angle, 0.2)
	end

	def accelerate
		@vx += Gosu::offset_x(@angle, 0.5)
		@vy += Gosu::offset_y(@angle, 0.5)
	end

	def turn_left(dt)
		if moving == true
			@angle -= 1 * dt / 3
		else
			@angle -= 0.5 * (@vx.abs + @vy.abs) + 1.5
		end
	end

	def turn_right(dt)
		if moving == true
			@angle += 1 * dt / 3
		else
			@angle += 0.5 * (@vx.abs + @vy.abs) + 1.5
		end
	end
	
	def move(dt)
		if (@x <= @skin.width / 2 + 1 || @x >= WinX - @skin.width / 2 + 1)
			@vx = -@vx
			@x = @skin.width / 2 + 1 if @x < @skin.width / 2 + 1
			@x = WinX - @skin.width / 2 + 1 if @x > WinX - @skin.width / 2 + 1
		end
		if (@y <= @skin.height / 2 + 1 || @y >= WinY - @skin.height / 2 + 1)
			@vy = -@vy
			@y = @skin.height / 2 + 1 if @y < @skin.height / 2 + 1
			@y = WinY - @skin.height / 2 + 1 if @y > WinY - @skin.height / 2 + 1
		end
		@x += @vx * dt / 15
		@y += @vy * dt / 15

		@vx *= 0.95
		@vy *= 0.95
	end

	def draw(distance)
		return 0 if Gosu::milliseconds - @lst < 1000
		if distance > 130
			s = 1
		# elsif distance < 70
		# 	s = 70 / 130
		else
			s = distance / 130
		end
		@skin.draw_rot(@x, @y, 2, @angle, 0.5, 0.5, s, s)
		@shield.draw(@x, @y) if @shield
	end

	def draw_on(distance)
		return 0 if Gosu::milliseconds - @lst < 1000
		if distance >= 130
			s = 1
		# elsif distance <= 70
		# 	s = 70 / 130
		else
			s = distance / 130
		end
		@skin_on.draw_rot(@x, @y, 2, @angle, 0.5, 0.5, s, s)
		if Gosu::milliseconds - @lst <= 3000
			@shield.draw(@x, @y) if @shield
		else
			@shield = nil
		end
	end

	def shoot(type)
		if type == 1 && bullet > 0
			@bullarr << Bullet.new(@angle, @x, @y, @vx, @vy, @who)
			@bullet -= 1
		elsif type == 2 && @rocket > 0
			@bullarr << Rocket.new(@angle, @x, @y, @vx, @vy, @who)
			@rocket -= 1
		end
		# @sound.play(0.08, 0.5)
		@bullarr = @bullarr.drop_while { |b| b.y <= (0 - (b.texture.height / 2)) || b.x <= (0 - (b.texture.width / 2)) || b.y >= (WinY + (b.texture.height / 2)) || b.x >= (WinX + (b.texture.width / 2)) }
		@bullarr = @bullarr.drop_while { |b| b.life < 1}
	end

	def recharge
		if @bullet < 10 && Gosu::milliseconds - @lst_r > 1000
			@bullet += 1
			@lst_r = Gosu::milliseconds 
		end
	end

	def bubble
		@lst = Gosu::milliseconds
		@shield = Bubble.new(@who) if @ns > 0
		@ns -= 1 if @ns > 0
	end

	def hit(force)
		return 0 if Gosu::milliseconds - @lst < 1000
		if @shield
			@shield.hit
			@shield = nil
		else
			@life -= force
			@boom.play(0.4, 2) if @life <= 0
			self.warp(@defx, @defy) if @life <= 0
		end
		return 1
	end

	def sp
		return 0 if Gosu::milliseconds - @lst < 1000
		return 1
	end
	def life
		@life
	end

end