#ifndef CHARSET_H
#define CHARSET_H
#ifdef __cplusplus
extern "C" {
#endif

extern void init_locale(void);
extern int deaccent(int ch);
extern int accent(int a, int c);

#ifdef __cplusplus
}
#endif
#endif /* CHARSET_H */
