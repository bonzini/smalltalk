DhbNumericalMethods_FILES = \
packages/numerics/Approximation.st packages/numerics/Basic.st packages/numerics/ChangeLog packages/numerics/Distributions.st packages/numerics/Functions.st packages/numerics/Integration.st packages/numerics/Matrixes.st packages/numerics/NumericsAdds.st packages/numerics/NumericsTests.st packages/numerics/Optimization.st packages/numerics/RNG.st packages/numerics/Statistics.st 
$(DhbNumericalMethods_FILES):
$(srcdir)/packages/numerics/stamp-classes: $(DhbNumericalMethods_FILES)
	touch $(srcdir)/packages/numerics/stamp-classes
