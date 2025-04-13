L = [0] * (2**6)

# Neutral basin around start
for i in [0]:
  L[i] = 10

# Adaptive path to global optimum
L[32] = 11
L[48] = 11
L[56] = 11
L[60] = 11
L[62] = 11

# Global optimum
L[63] = 20

for x in L:
  print(x)
