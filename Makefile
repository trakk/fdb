CFLAGS=	-W -Wall -I.. -pthread -g

.PHONY: all clean

all:
	OS=`uname`; \
	  test "$$OS" = Linux && LIBS="-ldl -lreadline" ; \
	  $(CC) $(CFLAGS) fdb.c  $$LIBS $(ADD) -o fdb `mysql_config --cflags --libs`;

clean:
	rm -rf fdb *.exe *.dSYM *.obj
