L = [0] * (2**6)

# Neutral basin around start
for i in [0]:
  L[i] = 10

# Path to local optimum
L[1] = 11
L[3] = 12
L[7] = 13

# Equal steepness path to global optimum
L[32] = 11
L[48] = 12
L[56] = 13
L[60] = 14
L[62] = 15

# Global optimum
L[63] = 20

for x in L:
  print(x)
