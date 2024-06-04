all:
	# install libgcrypt if not yet
	sudo apt-get install libgcrypt11-dev
	# remove all test files
	rm -f testfile*
	# compile the files. Include gcrypt library.
	gcc -o purenc purenc.c -lgcrypt -lm
	gcc -o purdec purdec.c -lgcrypt
clean:
	rm -f test* purenc purdec ._*