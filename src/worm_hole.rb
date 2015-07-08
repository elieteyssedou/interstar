class WormHole
	attr_reader :die, :x, :y, :angle
	def initialize(x, y, angle)
		@x = x
		@y = y
		@angle = angle
		# @animation = Gosu::Image::load_tiles("media/images/orb-stretch.png", 96, 192, :tileable => false)
		@animation = Gosu::Image::load_tiles("media/images/orb-u-stretch.png", 48, 192, :tileable => false)
		@sound = Gosu::Sample.new("media/samples/boom.mp3")
		# @animation = Gosu::Image::load_tiles("media/images/orb.png", 192, 192, :tileable => false)
		@die = false
		@bool = false
		@ret = true
		@begin = false
		@step = 1
		@birthday = Gosu::milliseconds
		@pass = false
	end

	def play
		@sound.play(0.4, 1)
	end

	def draw_in
		if @bool == false
			@t1 = Gosu::milliseconds / 100 % @animation.size
			@bool = true
		end
		t = Gosu::milliseconds / 100 % @animation.size
		@frame = ((@animation.size - 1) - (t - @t1))
		@animation[@frame].draw_rot(@x, @y, 3, @angle)
		if t == @animation.size - 1
			@bool = false
			@pass = true
		end
	end

	def draw_on
		size = 5
		if @bool == false
			@t1 = Gosu::milliseconds / 100 % size
			@bool = true
		end
		t = Gosu::milliseconds / 100 % size
		if @ret == false
			@frame = (t - @t1)
			@ret = true if @frame == size - 1
		else
			@frame = ((size - 1) - (t - @t1))
			@ret = false if @frame == 0
		end
		@animation[@frame + 1].draw_rot(@x, @y, 3, @angle)
		if t == size - 1
			@bool = false
			@pass = true
		end
	end

	def draw_out
		if @bool == false
			@t1 = Gosu::milliseconds / 100 % @animation.size
			@bool = true
		end
		t = Gosu::milliseconds / 100 % @animation.size
		@frame = t - @t1
		@animation[@frame].draw_rot(@x, @y, 3, @angle)
		if t == @animation.size - 1
			@die = true
			@bool = false
		end
	end

	def draw
		if @step == 1
			self.draw_in
			if @pass == true
				@step = 2
			end
		elsif @step == 2
			@pass = false
			self.draw_on
			@step = 3 if Gosu::milliseconds - @birthday >= 5000 && @pass == true
		else
			self.draw_out
		end
	end
end