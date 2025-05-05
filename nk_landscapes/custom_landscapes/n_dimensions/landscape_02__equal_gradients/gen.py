L = [0] * (2**6)

def count_ones(n):
  result = 0
  while n > 0:
    if n & 1 == 1:
      result += 1
    n = n >> 1
  return result

# Create gradient
for i in range(0, 64):
  L[i] = 1.1 ** abs(2 - count_ones(i))

for x in L:
  print(x)
