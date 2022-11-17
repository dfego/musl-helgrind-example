# gcc vs. musl-gcc helgrind example

This repository is a complete and simple example of some unexpected behavior
from helgrind when using a musl-built program. When even creating and joining
a trivial thread, "possible data race" errors are reported from helgrind.

As a complete example:

    $ make build
    $ make glibc
    docker-compose run --rm -it gcc gcc -Wall -lpthread -o main-glibc main.c
    docker-compose run --rm -it gcc valgrind --tool=helgrind ./main-glibc
    ==1== Helgrind, a thread error detector
    ==1== Copyright (C) 2007-2017, and GNU GPL'd, by OpenWorks LLP et al.
    ==1== Using Valgrind-3.18.1 and LibVEX; rerun with -h for copyright info
    ==1== Command: ./main-glibc
    ==1==
    ==1==
    ==1== Use --history-level=approx or =none to gain increased speed, at
    ==1== the cost of reduced accuracy of conflicting-access information
    ==1== For lists of detected and suppressed errors, rerun with: -s
    ==1== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
    $ make musl
    docker-compose run --rm -it gcc musl-gcc -Wall -lpthread -o main-musl main.c
    docker-compose run --rm -it gcc valgrind --tool=helgrind ./main-musl
    ==1== Helgrind, a thread error detector
    ==1== Copyright (C) 2007-2017, and GNU GPL'd, by OpenWorks LLP et al.
    ==1== Using Valgrind-3.18.1 and LibVEX; rerun with -h for copyright info
    ==1== Command: ./main-musl
    ==1==
    ==1== ---Thread-Announcement------------------------------------------
    ==1==
    ==1== Thread #2 was created
    ==1==    at 0x4058916: ??? (in /usr/local/lib/libc.so)
    ==1==    by 0x4056950: pthread_create (in /usr/local/lib/libc.so)
    ==1==    by 0x409B00F: ???
    ==1==    by 0x40564BB: pthread_exit (in /usr/local/lib/libc.so)
    ==1==
    ==1== ---Thread-Announcement------------------------------------------
    ==1==
    ==1== Thread #1 is the program's root thread
    ==1==
    ==1== ----------------------------------------------------------------
    ==1==
    ==1== Possible data race during read of size 4 at 0x409B010 by thread #2
    ==1== Locks held: none
    ==1==    at 0x40561C9: __tl_lock (in /usr/local/lib/libc.so)
    ==1==
    ==1== This conflicts with a previous write of size 4 by thread #1
    ==1== Locks held: none
    ==1==    at 0x4056219: __tl_unlock (in /usr/local/lib/libc.so)
    ==1==    by 0x4056A0A: pthread_create (in /usr/local/lib/libc.so)
    ==1==  Address 0x409b010 is 0 bytes inside data symbol "__thread_list_lock"
    ==1==
    ==1== ----------------------------------------------------------------
    ==1==
    ==1== Possible data race during write of size 8 at 0x409ABB8 by thread #2
    ==1== Locks held: none
    ==1==    at 0x405641B: pthread_exit (in /usr/local/lib/libc.so)
    ==1==
    ==1== This conflicts with a previous write of size 8 by thread #1
    ==1== Locks held: none
    ==1==    at 0x40569E3: pthread_create (in /usr/local/lib/libc.so)
    ==1==  Address 0x409abb8 is 152 bytes inside data symbol "builtin_tls"
    ==1==
    ==1== ----------------------------------------------------------------
    ==1==
    ==1== Possible data race during write of size 8 at 0x409ABC0 by thread #2
    ==1== Locks held: none
    ==1==    at 0x4056423: pthread_exit (in /usr/local/lib/libc.so)
    ==1==
    ==1== This conflicts with a previous write of size 8 by thread #1
    ==1== Locks held: none
    ==1==    at 0x40569EB: pthread_create (in /usr/local/lib/libc.so)
    ==1==  Address 0x409abc0 is 160 bytes inside data symbol "builtin_tls"
    ==1==
    ==1== ----------------------------------------------------------------
    ==1==
    ==1== Possible data race during read of size 1 at 0x4098923 by thread #1
    ==1== Locks held: none
    ==1==    at 0x4054D5B: __lock (in /usr/local/lib/libc.so)
    ==1==    by 0x4022424: __funcs_on_exit (in /usr/local/lib/libc.so)
    ==1==    by 0x10917A: func1 (in /host/main-musl)
    ==1==
    ==1== This conflicts with a previous write of size 1 by thread #2
    ==1== Locks held: none
    ==1==    at 0x405640C: pthread_exit (in /usr/local/lib/libc.so)
    ==1==  Address 0x4098923 is 3 bytes inside data symbol "__libc"
    ==1==
    ==1== ----------------------------------------------------------------
    ==1==
    ==1== Possible data race during write of size 1 at 0x4098923 by thread #1
    ==1== Locks held: none
    ==1==    at 0x4054D7B: __lock (in /usr/local/lib/libc.so)
    ==1==    by 0x4022424: __funcs_on_exit (in /usr/local/lib/libc.so)
    ==1==    by 0x10917A: func1 (in /host/main-musl)
    ==1==
    ==1== This conflicts with a previous write of size 1 by thread #2
    ==1== Locks held: none
    ==1==    at 0x405640C: pthread_exit (in /usr/local/lib/libc.so)
    ==1==  Address 0x4098923 is 3 bytes inside data symbol "__libc"
    ==1==
    ==1==
    ==1== Use --history-level=approx or =none to gain increased speed, at
    ==1== the cost of reduced accuracy of conflicting-access information
    ==1== For lists of detected and suppressed errors, rerun with: -s
    ==1== ERROR SUMMARY: 5 errors from 5 contexts (suppressed: 0 from 0)

I would expect the behavior with glibc, and not the behavior with musl. I'm
not sure whether there's an issue with musl or helgrind, but this is a first
step in starting to figure that out.
