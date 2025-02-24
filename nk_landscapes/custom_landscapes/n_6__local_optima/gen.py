L = [0] * (2**6)

# Neutral basin around start
for i in [1, 2, 4, 8, 16, 32, 5, 9, 12, 18, 20, 33, 36]:
  L[i] = 10

# Neutral path to global optimum
for i in [32, 48, 56, 60, 62]:
  L[i] = 10

# Path to local optimum
L[1] = 11
L[3] = 12
L[7] = 13

# Global optimum
L[63] = 20

for x in L:
  print(x)
