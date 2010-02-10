Gaviota Tablebases Probing Code v0.1
Copyright (c) 2010 Miguel A. Ballicora

This software provides the code needed to probe the Gaviota Endgame Tablebases.
It is designed to be portable to be called from programs running
in Linux and Windows. Most likely it will work in other OS but
it has not been tested. This is a beta version and it is not guaranteed
that the interface will not changed. At least until version 1.0 is
released. This software is under the X11 ("MIT") license (see below).

A very small set of tablebase files is included in this distribution 
for testing purposes (only 3 pieces). They are compressed with four
different compression schemes. For a more complete set, please download 
Gaviota from
http://sites.google.com/site/gaviotachessengine/ 
and generate the 4 and 5 piece tablebases. Instructions how to generate them
and compressed them are in the website.

"tbprobe" is distributed here as an example of how to probe the TBs.
The interface is relatively "low level" to make sure that performance won't suffer. 
Hopefully, the small program tbprobe is self explanatory. A more complete
documentation may be released in the future.
In the future I planned to support an interface with a FEN notation too.

To include this code in any engine or GUI, the following files should be
compiled and linked:

gtb-probe.c
decode.c
possatt.c
sysport/sysport.c  
compression/wrap.c
compression/huffman/hzip.c 
compression/lzma/LzmaEnc.c 
compression/lzma/LzmaDec.c 
compression/lzma/Alloc.c 
compression/lzma/LzFind.c 
compression/lzma/Lzma86Enc.c 
compression/lzma/Lzma86Dec.c 
compression/lzma/Bra86.c
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
compression/liblzf/lzf_c.c
compression/liblzf/lzf_d.c

The following files will be included 
decode.h  
gtb-probe.h  
possatt.h

plus all the *.h files in the folders:
sysport/
compression/
compression/bzip2-1.0.5/
compression/liblzf/
compression/zlib/
compression/lzma/
compression/huffman/

The following libraries should be linked in Linux
-lpthread
-lm

In Windows, the appropriate MT (multithreaded library should alos be linked)

These switches should be set in the compiler
-D NDEBUG
-D Z_PREFIX

The first one removes the assert code, and the second
one makes sure that some names in the zlib library will not
collision with other names in ther other compression library.

the file compile.sh is an example of how tbprobe can be
compiled in Linux using gcc.

Good luck with the tablebases!

Miguel

-----------------------------------------------------------------------------
This Software is distributed with the following X11 License,
sometimes also known as MIT license.
 
Copyright (c) 2010 Miguel A. Ballicora

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.

-----------------------------------------------------------------------------
This Software also contain the following compression libraries:
-----------------------------------------------------------------------------
LZMA: 
2009-02-02 : Igor Pavlov : Public domain 
-----------------------------------------------------------------------------
ZLIB License

/* zlib.h -- interface of the 'zlib' general purpose compression library
  version 1.2.3, July 18th, 2005

  Copyright (C) 1995-2005 Jean-loup Gailly and Mark Adler

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

  Jean-loup Gailly        Mark Adler
  jloup@gzip.org          madler@alumni.caltech.edu


  The data format used by the zlib library is described by RFCs (Request for
  Comments) 1950 to 1952 in the files http://www.ietf.org/rfc/rfc1950.txt
  (zlib format), rfc1951.txt (deflate format) and rfc1952.txt (gzip format).
*/
----------------------------------------------------------------------------
LZF:

Copyright (c) 2000-2007 Marc Alexander Lehmann <schmorp@schmorp.de>

Redistribution and use in source and binary forms, with or without modifica-
tion, are permitted provided that the following conditions are met:

  1.  Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

  2.  Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MER-
CHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPE-
CIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTH-
ERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

Alternatively, the following files carry an additional notice that
explicitly allows relicensing under the GPLv2: lzf.c lzf.h lzfP.h lzf_c.c
lzf_d.c
-----------------------------------------------------------------------------
