require 'gosu'

class LaunchScreen
	attr_reader :time

	def initialize
		@time = Gosu::milliseconds
		@mask = Gosu::Image.new("media/images/lsu.png")
		if WinX > @mask.width
			@BegX = (WinX / 2) - (@mask.width / 2) + 1
		else
			@BegX = 0
		end
		@SizeX = @mask.width
		if WinY > @mask.height
			@BegY = (WinY / 2) - (@mask.height / 2) + 1
		else
			@BegY = 0
		end
		@SizeY = @mask.height
	end

	def draw
		Gosu::draw_rect(0, 0, WinX, WinY, Gosu::Color.argb(0xff000000))
		1000.times do
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddaaffff))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddffaaff))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddffffaa))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddffffff))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddffffff))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddaaaaff))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddffaaaa))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddaaffaa))
  			Gosu::draw_rect(rand(@BegX..@BegX + @SizeX - 5), rand(@BegY..@BegY + @SizeY - 5), rand(0.35..3.5), rand(0.35..3.5), Gosu::Color.argb(0xddffffff))
  		end
		@mask.draw_rot(WinX / 2, WinY / 2, 100, 0)
		if Gosu::milliseconds - @time > 2500
			o = ((Gosu::milliseconds - @time) - 2500) / 10
			o = 0 if o < 0
			o = 255 if o > 255
			o = o << 24
			# o += 0x00000000
			Gosu::draw_rect(0, 0, WinX, WinY, Gosu::Color.argb(o))
		end
	end
end