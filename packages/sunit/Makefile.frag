SUnit_FILES = \
packages/sunit/SUnitPreload.st packages/sunit/SUnitScript.st packages/sunit/SUnitScriptTests.st packages/sunit/SUnit.st packages/sunit/SUnitTests.st 
$(SUnit_FILES):
$(srcdir)/packages/sunit/stamp-classes: $(SUnit_FILES)
	touch $(srcdir)/packages/sunit/stamp-classes
