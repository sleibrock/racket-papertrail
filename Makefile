# papertrail.rkt Makefile

RACO=raco
PROJECTNAME=racket-papertrail

test:
	$(RACO) test -x .

install_local:
	$(RACO) pkg install

remove_local:
	$(RACO) pkg remove $(PROJECTNAME) 

# end Makefile
