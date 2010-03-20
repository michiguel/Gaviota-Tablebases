                 Gaviota Tablebases Probing Code API
                Copyright (c) 2010 Miguel A. Ballicora
-----------------------------------------------------------------------------

This software provides C code to probe the Gaviota Endgame Tablebases.
It is released under then X11 ("MIT") license (see license.txt).

This API (Application Programming Interface) is designed to be as portable 
as possible. Functions could be called from Linux or Windows. 
Most likely it will work in other operating systems but it has not been 
tested. This API is a beta version and it is not guaranteed any type of
backward compatibility or to remain untouched, at least until version 
1.0 is released. 

A very small set of tablebase files is included in this distribution 
for testing purposes (only 3 pieces). They are compressed with four
different compression schemes. For a more complete set, please download 
Gaviota from
http://sites.google.com/site/gaviotachessengine/ 
and generate the 4 and 5 piece tablebases. Instructions how to generate
and compressed them are in the website.

"tbprobe" is distributed here as a tablebase probing example. The current API
is relatively "low level" to opimize performance. We hope the small program 
tbprobe is self explanatory. A more complete documentation may be 
released later.

In the future we planned to support an interface with a FEN notation and
an interface to bitbases. Thus, it is expected that some other functions
maybe added to this API.

Four different types of compression are provided. It is possible that in the
future some other compression schemes could be provided, but only if they
represent a serious improvement in speed or memory size. To maximize
backward compatibility between versions of programs and TBs, it is strongly
recommended that engine developers always support at least scheme 4 (tb_CP4), 
which is considered the default at this point. For that reason, it is 
suggested that testers always have a set of TBs compressed with scheme 4.

This API is designed to be multithreading friendly. Regions where the access 
to data by this API from two different threads could cause a problem were 
protected with a mutex.

-------------------------- How to use this API ------------------------------

To include this code in any engine or GUI, the following files should be
compiled and linked:

gtb-probe.c
gtb-dec.c
gtb-att.c
sysport/sysport.c  
compression/wrap.c
compression/huffman/hzip.c 
compression/liblzf/lzf_c.c
compression/liblzf/lzf_d.c
compression/zlib/zcompress.c
compression/zlib/uncompr.c
compression/zlib/inflate.c
compression/zlib/deflate.c
compression/zlib/adler32.c   
compression/zlib/crc32.c    
compression/zlib/infback.c  
compression/zlib/inffast.c  
compression/zlib/inftrees.c  
compression/zlib/trees.c     
compression/zlib/zutil.c
compression/lzma/LzmaEnc.c 
compression/lzma/LzmaDec.c 
compression/lzma/Alloc.c 
compression/lzma/LzFind.c 
compression/lzma/Lzma86Enc.c 
compression/lzma/Lzma86Dec.c 
compression/lzma/Bra86.c

The following files will be "included" 
gtb-probe.h  
gtb-dec.h  
gtb-att.h

plus all the *.h files in the folders, so set the proper -I flags:
sysport/
compression/
compression/huffman/
compression/liblzf/
compression/zlib/
compression/lzma/


The following libraries should be linked in Linux
-lpthread
-lm

In Windows, the appropriate MT (multithreaded library should be linked too)

These switches should be set in the compiler
-D NDEBUG
-D Z_PREFIX

The first one removes the assert code, and the second
one makes sure that some names in the zlib library will not
collision with names in other compression libraries.

-------------------------- COMPILATION EXAMPLE ------------------------------

The file compile.sh is an example of how tbprobe can be
compiled in Linux using gcc.

Rakefile.rb is the ruby version of Makefile. You have to install 'rake'
to execute it. This is what I use but you don't have to. It is provided
out of lazyness. I should probably remove it.

Good luck with the tablebases!

Miguel

*****************************************************************************

