/* $Id: //depot/rsynth/dict.h#12 $
*/
#ifndef DICT_H
#define DICT_H

#include "lang.h"

#ifdef __cplusplus
extern "C" {
#endif

extern char *dict_path;

extern int dict_init(const char *dictname);
extern void dict_term(void);

#ifdef __cplusplus
}
#endif

#endif /* DICT_H */
