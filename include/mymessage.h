#ifndef MYMESSAGE_H
#define MYMESSAGE_H

extern unsigned short mymessage_init(void);
extern void mymessage_deinit(void);
extern char * mymessage_getMessage(char *handler_key, char *postfix);

#endif // MYMESSAGE_H
