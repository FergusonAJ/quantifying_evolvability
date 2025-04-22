L = [0] * (2**6)

# Neutral basin near the starting point
for i in [0, 1, 2, 3]:
    L[i] = 8

# Path to a local optimum
for i in [4, 5, 6, 7, 15]:
    L[i] = 12

# Local optimum (not the best)
L[15] = 16

# Neutral path to global optimum
for i in [32, 40, 48, 56, 60, 62]:
    L[i] = 10

# Rugged peaks and bumps
for i in [8, 9, 10, 11, 12, 13, 14]:
    L[i] = 9

# Global optimum
L[63] = 20

for x in L:
    print(x)
