require 'digest/md5'

module ChocolateyVersions

	@@debug = false

	def self.debug(on)
		@@debug = on		
	end

	def self.md5sum_choco(path)
	    content = ::File.read(path)
	    md5 = Digest::MD5.hexdigest(content)
	    log("md5sum of choco is [#{md5}]")
	    return md5
	end

	def self.parse_old_format(data)
	  log("parsing old format")
	  rtn = '' 
	  lines = data.split("\n")
	  lines.each do |line|  	
	       if((line.include?('found')) && (line.include?('foundCompare') == false))
		  bits = line.split(':')
		  rtn = bits[1].gsub(' ','')
		end 
	  end
	  return rtn
	end

	def self.parse_new_format(data)
	  log("parsing new format")
	  lines = data.split("\n")
	  bits = lines[0].split(' ')
	  return bits[1]
	end

	def self.parse_version_data(data)
	   log(data)
	   rtn = ''
	   if(data.include?('found'))
	     rtn = parse_old_format(data)
	   else
	     rtn = parse_new_format(data)
	   end
	   log("parsed version is [#{rtn}]")
	   return rtn
	end

	def self.get_cached_version()
	  filename = 'c:\windows\temp\choco_cached_version'  
	  if(::File.exist?(filename)==true)
	    contents = ::File.read(filename)
	    bits = contents.split(':')
	    log("found cached version md5sum[#{bits[0]}] version[#{bits[1]}]")
	    return {'md5sum'=> bits[0],'version' => bits[1]}
	  else
	  	log("not found a cached version information")
	    return nil
	  end
	end

	def self.save_cached_version(md5sum,version)
	  filename = 'c:\windows\temp\choco_cached_version'
	  ::File.open(filename, 'w') { |file| file.write("#{md5sum}:#{version}") }
	  log("Saved cached version information md5sum[#{md5sum}] version[#{version}]")
	end

	def self.chocolatey_installed?
		rtn = false
		if(File.exist?(chocolatey_executable)==true)
			rtn = true
		end		
		log("chocolatey is installed #{rtn}")
		return rtn
	end

	def self.get_choco_version()
		if (chocolatey_installed?)			
			exe = chocolatey_executable
			md5sum = md5sum_choco(exe)
			cached_version = get_cached_version()
			if(cached_version.nil? == false)				
				if(cached_version['md5sum'] == md5sum)
					log("md5 sums are the same so returning cached version #{cached_version['version']}")
		    		return cached_version['version']
		    	else
		       		log("this is a new version of chocolatey")		    		
		   		end
		   	else
		   		version_data = `#{exe} version`
		 		version = parse_version_data(version_data).gsub('v','')
				log("Detected version is [#{version}]")
				save_cached_version(md5sum,version)
				return version
			end
		else
			log("version cannot be found because chocolatey is not installed")
			return nil
		end
	end

	def self.chocolatey_install
	  ci_keys = ENV.keys.grep(/^ChocolateyInstall$/i)
	  ci_keys.count > 0 ? ENV[ci_keys.first] : nil
	end

	def self.chocolatey_executable
	  "#{::File.join(chocolatey_install, 'bin', 'choco')}.exe"
	end

	def self.log(msg)		
		if(@@debug)
			Chef::Log.info("CHOCO: #{msg}")
		end
	end
end

