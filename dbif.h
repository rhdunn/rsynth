#ifdef HAVE_LIBDB 
#include <db.h>

#define DB_HANDLE DB *
#define DATUM DBT

#define DATUM_SIZE(d) d.size
#define DATUM_DATA(d) d.data

#define DATUM_SET(d,val,len) \
  do { memset(&d,0,sizeof(d)); \
       d.data = (val); \
       d.size = (len); \
     } while (0)

#define DB_OPEN_WRITE(db, path)                                      \
 do {                                                                \
   DB_INFO info;                                                     \
   memset(&info,0,sizeof(info));                                     \
   info.flags = DB_DUP;                                              \
   db_open(path, DB_HASH, DB_CREATE, 0644, NULL, &info, &db);       \
  } while (0) 
              
#define DB_OPEN_READ(db, path)                                       \
 do {                                                                \
   DB_INFO info;                                                     \
  memset(&info,0,sizeof(info));                                      \
  db_open(path, DB_UNKNOWN, DB_RDONLY, 0644, NULL, &info, &db);      \
 } while (0) 
              
#define DB_STORE(db, key, data) \
 db->put(db, NULL, &key, &data, 0)

#define DB_FETCH(db, key, data)             \
 do {                                       \
     data.flags = DB_DBT_MALLOC;            \
     data.data  = NULL;                     \
     db->get(db, NULL, &key, &data, 0);     \
    } while (0)
    
#define DB_CLOSE(db) db->close(db,0)
                    

#else  /* LIBDB */

#ifdef HAVE_LIBGDBM
#include <gdbm.h>
/* Don't force block size let gdbm/os decide */
#define BLOCK_SIZE 0

#ifndef GDBM_FAST
/* Tolerate older versions of gdbm ... */
#define GDBM_FAST 0
#endif                      



#define DB_HANDLE GDBM_FILE
#define DATUM datum
#define DATUM_SIZE(d) d.dsize
#define DATUM_DATA(d) d.dptr

#define DATUM_SET(d,val,len) do { d.dptr = (val); d.dsize = (len); } while (0)
#define DB_STORE(db, key, data) gdbm_store(db, key, data, GDBM_INSERT)
#define DB_OPEN_WRITE(db, path) db = gdbm_open(path, BLOCK_SIZE, GDBM_WRCREAT | GDBM_FAST, 0644, NULL)
#define DB_OPEN_READ(db, path) db = gdbm_open(path, BLOCK_SIZE, GDBM_READER, 0644, NULL)
#define DB_CLOSE(db) gdbm_close(db)
#define DB_FETCH(db,key,data) \
  data = gdbm_fetch(db, key)

#endif /* LIBGDBM */
#endif /* LIBDB */

