L = [0] * (2**6)

# Starting point
L[0] = 1

# Path to local optima
L[1] = 1.1 ** 1
L[3] = 1.1 ** 2

# Local optima
L[7] = 1.1 ** 3

# Adaptive path to global optimum
L[32] = 1.1 ** 1
L[48] = 1.1 ** 2
L[56] = 1.1 ** 3
L[60] = 1.1 ** 3 
L[62] = 1.1 ** 4

# Global optimum
L[63] = 1.1 ** 5

for x in L:
  print(x)
