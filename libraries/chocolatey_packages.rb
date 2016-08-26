
module ChocolateyPackages

	@@debug = false

	def self.debug(on)
		@@debug = on		
	end

	def self.log(msg)		
		if(@@debug)
			Chef::Log.info("CHOCO: #{msg}")
		end
	end

	def self.is_package_listed?(name,version,data)
		log("is package listed with name:[#{name}] version[#{version}]")
		items = data.gsub("\r",'').split("\n")
		items.each do |item|			
			Chef::Log.debug(">> #{item} <<")
			if((item.include?(name)) && (item.include?('[Pending]') == false))
				#ok we have found a match , now check the version 
				if(version.to_s != '')
					# We have a version specified so check that too 
					if(item.include?(version))
						log("package #{name} #{version} is installed and on same version as specified [#{item}]")
						return true 
					else
						log("package #{name} is installed but not on same version [#{item}]")
						return false
					end
				end
				log("package #{name} is installed version not checked [#{item}]")
				return true
			end			
		end
		log("package #{name} is not installed")
		return false
	end

end

