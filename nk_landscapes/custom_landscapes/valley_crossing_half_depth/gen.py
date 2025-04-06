L = [0] * (2**6)

# Neutral basin around start
for i in [0]:
  L[i] = 10

# Deleterious path to global optimum
L[32] = 9.5
L[48] = 9
L[56] = 8.5

# Global optimum
L[60] = 20
L[62] = 20
L[63] = 20

for x in L:
  print(x)
