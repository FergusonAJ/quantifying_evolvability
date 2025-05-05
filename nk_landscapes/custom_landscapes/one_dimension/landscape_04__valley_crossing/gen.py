L = [0] * (2**6)

# Neutral basin around start
for i in [0]:
  L[i] = 1

# Deleterious path to global optimum
L[32] = 0.95 ** 1
L[48] = 0.95 ** 2
L[56] = 0.95 ** 3

# Global optimum
L[60] = 1.1 ** 4

for x in L:
  print(x)
