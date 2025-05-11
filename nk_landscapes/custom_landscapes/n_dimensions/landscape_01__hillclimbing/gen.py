L = [0] * (2**6)

def count_ones(n):
  result = 0
  while n > 0:
    if n & 1 == 1:
      result += 1
    n = n >> 1
  return result

# Neutral basin around start
for i in [0]:
  L[i] = 1


# Create gradient
for i in range(1, 64):
  L[i] = 1.1 ** count_ones(i)

for x in L:
  print(x)
