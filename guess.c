/*
    Copyright (c) 1994,2001-2002 Nick Ing-Simmons. All rights reserved.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "darray.h"
#include "charset.h"
#include "text.h"
#include "phones.h"
#include "lang.h"
#include "english.h"
#include "say.h"


lang_t *lang = &English;

unsigned
xlate_string(char *string, darray_ptr phone)
{
 abort(); /* just a stub */
}

int main(int argc,char *argv[])
{
 darray_t phone;
 darray_init(&phone, sizeof(char), 128);
 init_locale();
 rule_debug = 1;
 while (--argc)
  {
   char *s = *++argv;
   NRL(s,strlen(s),&phone);
   darray_append(&phone,0);
   printf("%s [%s]\n",s,(char *) darray_find(&phone,0));
   phone.items = 0;
  }
 return 0;
}


