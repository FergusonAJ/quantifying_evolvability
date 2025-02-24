import random

n = 5
k = 2
states = 2**(k+1)
p = 0.2

print(f'N={n}')
print(f'K={k}')
for i in range(n):
  for j in range(states):
    if random.uniform(0,1) < p:
      print(1)
    else:
      print(0)
