require 'date'

$target   = 'tbprobe'
$sources  = 'sources.txt'

#switches_gcc = '-lpthread -lm -Wwrite-strings -Wshadow -Wconversion -W -Wall -Wextra -Wcast-qual -ansi -pedantic -O2 '
$switches_gcc = '-lpthread -lm -Wwrite-strings -Wshadow -Wconversion -W -Wall -Wextra -O2 '
$switches_icc = '-lpthread -Wall -O2 '
#-wd981,593,2259

$include = []
$include << 'sysport/'
$include << 'compression/'
$include << 'compression/liblzf/'
$include << 'compression/zlib/'
$include << 'compression/lzma/'
$include << 'compression/huffman/'

$dswitches = []
$dswitches << 'Z_PREFIX'
$dswitches << 'NDEBUG'

$profile_data_folder = '/media/bigdisk/profdata/'
$benchfile = 'pgo-medium.txt'

$sync_line = ''

$windows_destiny	= '/home/miguel/Desktop/tbprobe-windows'
$version_sensitive = 'tbprobe.o'
#------------------------------------------------------------------------------------
$errors_comp = 'errors_comp.txt'
$errors_link = 'errors_link.txt'

def build_clist filelist
	sl = []
	File.open filelist, "r" do |f|
		lines = f.readlines
		lines.each do |line|
			if line != nil
				line = line.chomp.strip
				if line != ''
					firstchar = line[0,1]
					if firstchar != ';'
						sl << line
					end
				end
			end	
		end
	end
	return sl
end

def build_c c
	elements = []
	elements << $compiler
	elements << series('-I', $include)
	elements << series('-D', $dswitches)
	elements << $switches
	elements << '-c'
	elements << c
	line = 	glue(elements)
end

def series s, list
	build = ''
	list.each do |x|
  		build = build+' '+s+' '+x
	end
	build = build.strip
end

def glue list
	build = ''
	list.each do |x|
  		build = build+' '+x
	end
	build = build.strip
end

#------------------------------------------------------------------------------------
def sources_line filelist
	sources = ''
	File.open filelist, "r" do |f|
		lines = f.readlines
		lines.each do |line|
			if line != nil
				line = line.chomp.strip
				firstchar = line[0,1]
				if firstchar != ';'
					sources += line + ' '
				end
			end	
		end
	end
	sources = sources.strip
	return sources
end

def rebuild_line
	elements = []
	elements << $compiler
	elements << series('-I', $include)
	elements << series('-D', $dswitches)
	elements << $switches
	elements << '-o'
	elements << $target
	elements << sources_line($sources)
	line = 	glue(elements)
end

def go_rebuild s
	tf = 'temporary-output.txt'
	puts "compiling " + $target + "...\n"
	# actual compilation
	ok = system(s)
	if ok
		# get version
		system ('./'+ $target +' -v > ' + tf)
		out = `cat temporary-output.txt`
		puts out
		cleanfile(tf)
		puts "done\n"
	else
		puts 'Compiling errors.'
	end
end

def cleanfile x
	if File.exist?(x)
		system ('rm ' + x)
	end
end

def cleanlist filelist
	filelist.each do |f|
		cleanfile(f)
	end
end

def cleanpattern p
	x = Dir[p]
	cleanlist(x)
end

#--------------#
# name target #
#--------------#

task :name do
	File.open "progname.h", 'w' do |f|
		f.write '#define PROGRAM_NAME "'+ $target +'"'+"\n"
	end
end


#--------------#
# sync         #
#--------------#

task :sync do
	if $sync_line != ''
		system($sync_line)
	end
end


#--------------#
# Clean target #
#--------------#

task :remove_h_sensitive do
	if (!FileUtils.uptodate?($version_sensitive, 'version.h'))
		cleanfile($version_sensitive)
	end
end

task :clean_target => [:remove_h_sensitive] do
	cleanfile($target)
end

#----------------#
# Clean pgo data #
#----------------#

task :clean_pgodata do
	cleanpattern($profile_data_folder+'*.dyn')
	cleanpattern($profile_data_folder+'*.dpi')
	cleanpattern($profile_data_folder+'*.dpi.lock')
end

#--------------#
# DEFAULT TASK #
#--------------#

task :default => :gcc2 do
	puts " "
end

#--------------#
# GCC TASK #
#--------------#

task :gcc => [:clean_target, :sync, :name] do
	$compiler = 'gcc'
	$switches = $switches_gcc
	go_rebuild(rebuild_line)
end


#--------------#
# GCC TASK #
#--------------#

task :gdb => [:clean_target, :sync, :name] do
	$compiler = 'gcc'
	$switches = '-g ' + $switches_gcc
	go_rebuild(rebuild_line)
end

#--------------#
# GCC TASK #
#--------------#

task :debug => [:clean_target, :sync, :name] do
	$compiler = 'gcc'
	$switches = '-D DEBUG ' + $switches_gcc
	go_rebuild(rebuild_line)
end

#--------------#
# INTEL TASK   #
#--------------#

task :intel => [:clean_target, :sync, :name] do
	$compiler = 'icc'
	$switches = $switches_icc
	go_rebuild(rebuild_line)
end


#--------------#
# PGO BEGIN    #
#--------------#

task :pgo_begin => [:clean_target, :clean_pgodata, :sync, :name] do

	$compiler = 'icc'
	$switches = '-I lzma -D GCCLINUX -lpthread -Wall -wd981,593,2259 -O2 '
	$switches += '-prof-gen -prof-dir '+$profile_data_folder

	errorfile = 'icc-err-begin.txt'
	cleanfile(errorfile)
	li = rebuild_line+' 2> '+errorfile
	go_rebuild(li)
	system = ('cat '+errorfile)

end


#------------#
# PGO TEST   #
#------------#

task :test => [:pgo_begin] do
	system ('./'+$target+' < '+$benchfile)
end


#------------#
# PGO END    #
#------------#

task :pgo_end => [:test, :name] do

	$compiler = 'icc'
	$switches = '-I lzma -D GCCLINUX -lpthread -Wall -wd981,593,2259 -O2 '
	$switches += '-prof-use -ipo -prof-dir '+$profile_data_folder

	errorfile = 'icc-err-ending.txt'
	cleanfile(errorfile)
	li = rebuild_line+' 2> '+errorfile
	go_rebuild(li)
	system = ('cat '+errorfile)

end

task :pgo => :pgo_end

#--------------#
# GCC SEE      #
#--------------#

task :see do
	$compiler = 'gcc'
	$switches = $switches_gcc
	puts rebuild_line
end


###################################################################################

require 'fileutils.rb'

def to_obj x
	newname = File.basename(x, File.extname(x)) + '.o'
	arr = File.split(x.strip)
	t = File.join(arr[0],newname)
	t
end

def build_clist filelist
	sl = []
	File.open filelist, "r" do |f|
		lines = f.readlines
		lines.each do |line|
			if line != nil
				line = line.chomp.strip
				if line != ''
					firstchar = line[0,1]
					if firstchar != ';'
						sl << line
					end
				end
			end	
		end
	end
	return sl
end

def build_olist clist
	olist = []
	clist.each do |x|
		olist << to_obj(x)
	end
	return olist
end

def build_objects compiler, switches, clist
	ok = 1 == 1;
	clist.each do |src|
		unless FileUtils.uptodate?(to_obj(src), src) 
			print src + ': '
			ok = ok && compile_o(compiler,switches,src)
			if (ok)
				puts  '->  ' + to_obj(src)
			else
				puts  '=> ERROR'				
			end
			if (!ok)
				break
			end
		end
	end
	return ok
end


def compile_line compiler, switches, c
	elements = []
	elements << compiler
	elements << series('-I', $include)
	elements << series('-D', $dswitches)
	elements << switches
	elements << '-c'
	elements << '-o'
	elements << to_obj(c)
	elements << c
	line = 	glue(elements)
end

def link_line compiler, switches, target, olist
	elements = []
	elements << compiler
	#elements << series('-I', $include)
	#elements << series('-D', $dswitches)
	elements << switches
	elements << '-o'
	elements << target
	elements << glue(olist)
	line = 	glue(elements)
end


def compile_o compiler,switches, src
	y = compile_line(compiler,switches,src)	
	system(y + ' 2> ' + $errors_comp)
end

def link compiler,switches,target,olist
	y = link_line(compiler,switches,target,olist)
	system(y + ' 2> ' + $errors_link)
end

def clean_objects clist
	clist.each do |src|
		o = to_obj(src) 
		cleanfile(o)
	end
end

def errors2screen
	if File.exist?('errors_comp.txt')
		puts `cat errors_comp.txt`
	end
	if File.exist?('errors_link.txt')
		puts `cat errors_link.txt`
	end
end

#--------------#
# gcc2         #
#--------------#

task :gcc2 => [:clean_target, :sync, :name] do
	$compiler = 'gcc'
	$switches = $switches_gcc
	c_array = build_clist($sources)
	o_array = build_olist(c_array)
	ok = build_objects($compiler,$switches, c_array)
	ok = ok && link($compiler,$switches, $target, o_array)

	errors2screen

	if ok
		# get version
		tf = 'temporary-output.txt'
		system ('./'+ $target +' -v > ' + tf)
		out = `cat temporary-output.txt`
		puts out
		cleanfile(tf)
		puts "done!\n"
	else
		puts '*** Compiling errors ***'
	end

end

#--------------#
# CLEAN        #
#--------------#

task :clean => [:clean_target] do
	clean_objects(build_clist($sources))
end

task :clobber => [:clean] do
	list = Dir['*~']
	list.each do |src|
		puts(src)
		cleanfile(src)
	end
	list = Dir['errors_*']
	list.each do |src|
		puts(src)
		cleanfile(src)
	end
end

#--------------#
# DEPLOY       #
#--------------#

def copyline dpath, name
	el = []
	el << 'cp'
	el << name
	el << File.join(dpath,name)
	line = glue(el) 
	return line
end

def uncopyline dpath, name
	el = []
	el << 'cp'
	el << File.join(dpath,name)
	el << name
	line = glue(el) 
	return line
end

def cmpline dpath, name
	el = []
	el << 'cmp'
	el << name
	el << File.join(dpath,name)
	line = glue(el) 
	return line
end

def diffline dpath, name
	el = []
	el << 'diff --ignore-space-change --ignore-blank-lines --ignore-all-space --brief'
	el << name
	el << File.join(dpath,name)
	line = glue(el) 
	return line
end

def xxdiffline dpath, x
	el = []
	el << 'xxdiff --ignore-space-change --ignore-blank-lines --ignore-all-space --merge'
	el << x
	el << File.join(dpath,x)
	line = glue(el) 
end


def uncopy_if_notupdated dpath, x
	ok = system(cmpline(dpath,x))
	if (!ok && !FileUtils.uptodate?(x, File.join(dpath,x)))
		system uncopyline(dpath,x)		
	end
end

def multichomp x
	y = x
	z = x.chomp
	while z != y do
		y = z
		z = z.chomp
	end
	z
end

$home_dir = '/home/miguel'
$current_dir = '/media/bigdisk/gaviotadev/'

def valid_destination x
	ok = x != nil && x != '' && x != './' && x != $home_dir && x != ($home_dir+'/')
	ok
end

def currdir
	`pwd`.chomp 
end

task :get_homedir do
	$home_dir = `echo $HOME`.chomp
end

task :get_currentdir do
	$current_dir  = `pwd`.chomp + '/'
end

def select_folder default
	if (File.exist?(default))
		system 'zenity --file-selection --directory --filename='+default+'> zenityanswer.txt'
	else
		owndir = currdir + '/'
		system 'zenity --file-selection --directory --filename='+owndir+'> zenityanswer.txt'
	end
	folder =`cat zenityanswer.txt`
	folder = multichomp(folder)
	default = folder
	default
end

task :select_deploy_destiny => [:get_homedir] do
	$windows_destiny = select_folder($windows_destiny)
end

task :deploy => [:gcc2, :select_deploy_destiny, :get_homedir, :get_currentdir]  do

	if (valid_destination($windows_destiny))

		destiny = $windows_destiny	
		own_location = $current_dir 

		rs = []
		rs << 'rsync'
		rs << '-vr'
		rs << '-f"- .git"'
		rs << '-f"+ */"'
		rs << '-f"- *"'
		rs << own_location
		rs << destiny
		system glue(rs)

		c_array = build_clist($sources)
		c_array.each do |x|
			system copyline(destiny,x)		
		end

		h_array = Dir['*.h']
		h_array.each do |z|
			system copyline(destiny,z)		
		end
	
		i_array = $include
		i_array.each do |x|
			pattern = File.join(x,'*.h')
			h_array = Dir[pattern]
			h_array.each do |z|
				system copyline(destiny,z)		
			end
		end

		puts 'Deployed project to: '+destiny

	else
		if ($windows_destiny == nil || $windows_destiny.strip == '')
			puts 'Cancelled deployment'
		else
			puts 'Cancelled deployment to: '+$windows_destiny	
		end
	end

end


task :inploy => [:select_deploy_destiny, :get_homedir, :get_currentdir] do

	destiny = $windows_destiny	

	c_array = build_clist($sources)
	c_array.each do |x|
		uncopy_if_notupdated(destiny,x)
	end

	h_array = Dir['*.h']
	h_array.each do |z|
		uncopy_if_notupdated(destiny,z)
	end
	
	i_array = $include
	i_array.each do |x|
		pattern = File.join(x,'*.h')
		h_array = Dir[pattern]
		h_array.each do |z|
			uncopy_if_notupdated(destiny,z)
		end
	end

	puts 'In-ployed project from: '+destiny
end

#--------------#
# COMPARE      #
#--------------#

def checkdiff dpath,z
		if (system(diffline(dpath,z)))
			puts '--------------------------------> '+z+': is ok'
		else
			system(xxdiffline(dpath,z))
		end
end

task :compare => [:select_deploy_destiny, :get_homedir, :get_currentdir] do

	destiny = $windows_destiny	

	c_array = build_clist($sources)
	c_array.each do |z|
		checkdiff(destiny,z)
	end

	h_array = Dir['*.h']
	h_array.each do |z|
		checkdiff(destiny,z)
	end
	
	i_array = $include
	i_array.each do |x|
		pattern = File.join(x,'*.h')
		h_array = Dir[pattern]
		h_array.each do |z|
			checkdiff(destiny,z)
		end
	end

	puts 'In-ployed project from: '+destiny

end

#--------------#
# SPLINT       #
#--------------#

task :splint do
	system ('rm splint.txt')
	c_array = build_clist($sources)
	c_array.each do |s|
		system './splintcheck.sh '+s
	end
end


#--------------#
# TO WEBFOLDER #
#--------------#
$webfolder = ''

task :select_webfolder => [:get_homedir] do
	$webfolder = select_folder($webfolder)
end

task :to_web => [:intel, :get_homedir, :select_webfolder] do
	ok = false
	if (valid_destination($webfolder))
		ok = system copyline($webfolder, $target)
	end
	if (ok)
		puts 'succesful copy of '+ $target
	else
		puts 'failed to copy '+ $target
	end
end



#--------------#
# DUMMY TASK   #
#--------------#

task :dummy do
	puts "dummy test\n"
end








