L = [0] * (2**6)

for i in [0, 32, 48, 56, 60, 62]:
  L[i] = 10

for i in [63]:
  L[i] = 20

for x in L:
  print(x)
