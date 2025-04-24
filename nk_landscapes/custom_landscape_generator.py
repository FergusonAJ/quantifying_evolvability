import sys
import math

if len(sys.argv) != 3:
  print('Error! Expected exactly two command line arguments:')
  print('  1. The genotype-to-fitness file to read')
  print('  2. The lookup table file to write')
  exit(1)

input_filename = sys.argv[1]
output_filename = sys.argv[2]

genotype_fitnesses = []
with open(input_filename, 'r') as in_fp:
  for line in in_fp:
    line = line.strip()
    if line == '':
      continue
    genotype_fitnesses.append(float(line))

N = math.log(len(genotype_fitnesses), 2)
if N % 1 != 0:
  print('Error! Number of genotypes must be a power of two!')
  print('Given genotypes:', len(genotype_fitnesses))
  exit(1)
N = int(N)

# Create lookup table
lookup_table = []
for row_idx in range(N):
  lookup_table.append([0] * (2**N))

for genotype in range(2**N):
  bitstring = bin(genotype)[2:]
  bitstring = '0' * (N - len(bitstring)) + bitstring
  bitstring = bitstring + bitstring
  for n in range(N):
    endpoint = len(bitstring) - n
    col_str = bitstring[(endpoint - N):endpoint]
    col = int(col_str, 2)
    lookup_table[n][col] = genotype_fitnesses[genotype] / N

with open(output_filename, 'w') as out_fp:
  out_fp.write('# Custom landscape generated from: ' + input_filename + '\n')
  out_fp.write(f'N = {N}\n')
  out_fp.write(f'K = {N-1}\n')
  for row in lookup_table:
    for col in row:
      out_fp.write(f'{col}\n')
