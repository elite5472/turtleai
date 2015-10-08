require 'yaml'
require 'fileutils'

def combine(file, path, ignore = [])
	dependencies = File.open(file).read().scan(/require\s+"(.+)"\s*;?\s*/)
	code = File.open(file).read().gsub(/require\s+"(.+)"\s*;?\s*/, '')
	
	out = ""
	
	dependencies.each do |d|
		if !ignore.include? d[0]
			out = out + "\n" + combine("#{path}/#{d[0]}.lua", path, ignore)
			ignore << d[0]
		end
	end
	
	out = out + "\n" + code 
	return out.gsub(/^\s*$\n/, '')
end

FileUtils.mkdir_p "bin" if !File.directory? "bin"
File.write("bins.yml", "") if !File.exists? "bins.yml"

bins = YAML.load_file('bins.yml')

bins = bins || {}

Dir["app/*.lua"].each do |f|
	app = File.basename(f, ".lua");
	code = ""
	if File.exists? "bin/#{app}.lua"
		code = File.read("bin/#{app}.lua")
	end
	
	newcode = combine(f, 'src')
	
	if code != newcode
		File.write("bin/#{app}.lua", newcode)
		puts "Uploading #{app} to pastebin..."
		bins["#{app}.lua"] = "pastebin get " + File.basename(`pastebin -f bin/#{app}.lua`).gsub("\n", "") + " #{app}"
		puts bins["#{app}.lua"]
	end
end

File.write('bins.yml', bins.to_yaml)

readme = "
Turtle AI
=========

Turtle AI is a project to develop turtles that leverage the BDI (Beliefs, Desires, Intentions) planning model to aid the player with numerous tasks.

Link to Research Paper (In progress): https://www.overleaf.com/read/qvjhxqfxdywk

The project uses make.rb to dynamically prepare lua scripts for use within ComputerCraft. The pastebin commands bellow are dynamically updated.

```yaml
#{bins.to_yaml}
```
"

File.write('README.md', readme)