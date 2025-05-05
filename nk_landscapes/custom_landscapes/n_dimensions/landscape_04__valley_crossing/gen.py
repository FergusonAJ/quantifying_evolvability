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
  num_ones = count_ones(i)
  if num_ones == 0:
    L[i] = 1
  elif num_ones >= 4:
    L[i] = 1.1 ** 2
  else:
    L[i] = 0.95 ** num_ones

for x in L:
  print(x)
