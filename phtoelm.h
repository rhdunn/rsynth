/* $Id: //depot/rsynth/phtoelm.h#14 $
*/
struct rsynth_s;
extern unsigned phone_to_elm (char *s, int n, darray_ptr elm, darray_ptr f0);
extern void say_pho(struct rsynth_s *rsynth, const char *path, int dodur,char *phoneset);

