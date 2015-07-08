class Vessel
	attr_reader :angle, :bullarr, :width, :height, :x, :y, :who, :vroom, :rocket, :boom
	attr_accessor :score


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
		@boom = Gosu::Sample.new("media/samples/boom.mp3")
		@x = @y = @vx = @vy = @angle = 0.0
		@bullarr = Array.new
		@width = @skin.width
		@height = @skin.height
		@score = 0
		@defx = defx
		@defy = defy
	end

	def warp(x, y)
		@lst = Gosu::milliseconds
		@shield = Bubble.new(@who)
		@rocket = 3
		@x = x
		@y = y
		@life = 3
	end

	def accelerate
		@vx += Gosu::offset_x(@angle, 0.5)
		@vy += Gosu::offset_y(@angle, 0.5)
	end

	def turn_left(dt)
		@angle -= 1 * dt / 3
	end

	def turn_right(dt)
		@angle += 1 * dt / 3
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

	def draw
		@skin.draw_rot(@x, @y, 2, @angle)
		@shield.draw(@x, @y) if @shield
	end

	def draw_on
		@skin_on.draw_rot(@x, @y, 2, @angle)
		if Gosu::milliseconds - @lst <= 3000
			@shield.draw(@x, @y) if @shield
		else
			@shield = nil
		end
	end

	def shoot(type)
		if type == 1
			@bullarr << Bullet.new(@angle, @x, @y, @vx, @vy, @who)
		elsif type == 2 && @rocket > 0
			@bullarr << Rocket.new(@angle, @x, @y, @vx, @vy, @who)
			@rocket -= 1
		end
		# @sound.play(0.08, 0.5)
		@bullarr = @bullarr.drop_while { |b| b.y <= (0 - (b.texture.height / 2)) || b.x <= (0 - (b.texture.width / 2)) || b.y >= (WinY + (b.texture.height / 2)) || b.x >= (WinX + (b.texture.width / 2)) }
		@bullarr = @bullarr.drop_while { |b| b.life < 1}
	end

	def hit(force)
		if @shield
			@shield.hit
			@shield = nil
		else
			@life -= force
			self.warp(@defx, @defy) if @life <= 0
		end
	end

	def life
		return @life + @shield.life if @shield
		@life
	end

end