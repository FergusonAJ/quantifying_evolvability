def factorial(n):
  res = 1
  for i in range(1, n + 1):
    res *= i
  return res

def n_choose_k(n, k):
  return factorial(n) / (factorial(k) * factorial(n-k))

def interpolate_color(p, col_a, col_b):
  r_start = col_a[0]
  r_end = col_b[0]
  r_range = r_end - r_start
  g_start = col_a[1]
  g_end = col_b[1]
  g_range = g_end - g_start
  b_start = col_a[2]
  b_end = col_b[2]
  b_range = b_end - b_start
  r = int(r_start + p * r_range)
  g = int(g_start + p * g_range)
  b = int(b_start + p * b_range)
  return (r, g, b)
