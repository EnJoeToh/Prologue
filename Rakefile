
desc 'sort'
task :sort do
	Dir['./*.dat'].each do |path|
		data = File.read path
		file = File.open("#{path}.sorted", 'w')
		data.gsub(/\s/, '').split(//).sort.each_slice(40) do |arr|
			file.puts arr.join('')
		end
		file.close
	end
end
