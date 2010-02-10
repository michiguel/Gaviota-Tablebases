#include "str64.h"
#include "sysport.h"

extern char *
llu2str (uint64_t x, char *s)
{
	char buf[32];
	char digitch[10] = {'0','1','2','3','4','5','6','7','8','9'};
	uint64_t m = 0;
	char *p;
	int i;
	

	buf[0] = '\0'; /* start with terminated string to silence splint */

	p = s;
	i = 0;
	while (x > 0) {
		m = x % 10;
		buf[i++] = digitch[(int)m];
		x -= m;		
		x /= 10;
	}
	if (i == 0) {
		*s++ = digitch[0];
	} else {
		while (i-- > 0) {
			*s++ = buf[i];
		}
	}
	*s = '\0';
	return p;
}

