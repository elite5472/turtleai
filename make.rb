require 'yaml'

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
		bins["#{app}.lua"] = "pastebin get " + File.basename(`pastebin -f bin/#{app}.lua`).gsub("\n", "") + " #{app}"
	end
end

File.write('bins.yml', bins.to_yaml)