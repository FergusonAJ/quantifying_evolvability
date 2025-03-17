L = [0] * (2**6)

# Neutral basin around start
for i in [0]:
  L[i] = 10

# Neutral path to global optimum
for i in [32, 48, 56, 60, 62]:
  L[i] = 10

# Path to local optimum
L[1] = 14

# Global optimum
L[63] = 20

for x in L:
  print(x)
