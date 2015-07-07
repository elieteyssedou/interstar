task :default do
	sh 'ruby src/main.rb'
end

task :install do
	sh 'brew update'
	sh 'brew install sdl2 libogg libvorbis'
	sh 'sudo gem install gosu'
	puts 'Succefully Installed !'
end