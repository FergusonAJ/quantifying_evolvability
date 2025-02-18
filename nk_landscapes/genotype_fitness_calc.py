def parse_input():
    """
    Reads input from the user and extracts:
    - N (number of genes)
    - K (number of dependencies per gene)
    - Lookup table (N rows, 2^(K+1) columns)
    """
    print("Paste input:")

    lines = []
    while True:
        line = input().strip()
        if line == "":
            break
        lines.append(line)

    # Extract N and K
    N = int(lines[0].split('=')[1])  
    K = int(lines[1].split('=')[1])  

    # The lookup table has N rows and 2^(K+1) columns
    num_columns = 2 ** (K + 1)  
    lookup_tables = []

    # Read lookup table values row by row
    for i in range(N):
        row = []
        for j in range(num_columns):
            row.append(int(lines[2 + i * num_columns + j]))  
        lookup_tables.append(row)  

    return N, K, lookup_tables

def generate_bit_combinations(K):
    """
    Generates all possible K+1 bit combinations for column headers.
    
    Example for K=2:
    ['000', '001', '010', '011', '100', '101', '110', '111']
    """
    combinations = []
    for i in range(2 ** (K + 1)):
        binary_str = ""
        num = i
        for _ in range(K + 1):  
            binary_str = str(num % 2) + binary_str
            num = num // 2
        while len(binary_str) < K + 1:  
            binary_str = "0" + binary_str
        combinations.append(binary_str)
    return combinations

def print_lookup_table(N, K, lookup_tables):
    """
    Prints the lookup table in the format:
        000  001  010  011 ...
    b0   1    0    1    0
    b1   0    1    1    1
    ...
    """
    bit_combinations = generate_bit_combinations(K)

    # Print the header row (bit combinations)
    print(" ", " ".join(bit_combinations))

    # Print each row labeled with b0, b1, b2, ...
    for i in range(N):
        row_label = "b" + str(i)  # Label for each row
        row_values = "  ".join(str(x) for x in lookup_tables[i])  # Row values
        print(row_label, row_values)

def generate_interactions(N, K):
    """
    Generates a table of dependencies for each gene.
    Each gene is influenced by itself and K neighbors.
    """
    interactions = []
    for i in range(N):
        indices = []
        for j in range(K + 1):
            # Read from right to left (bit 0 is far right, bit 1 is one to the left, etc)
            first_index = N - (1 + i + K)
            index = (first_index + j) % N
            indices.append(index)
        interactions.append(indices)
    return interactions

def get_substring(bitstring, indices):
    """
    Extracts a K+1 length substring from a bitstring based on the dependency indices.
    """
    result = ""
    for j in indices:
        result += bitstring[j]  
    return result  

def binary_to_decimal(binary_str):
    """
    Converts a binary string to a decimal integer.
    """
    return int(binary_str, 2)  

def calculate_fitness(bitstring, N, K, lookup_tables):
    """
    Computes the total fitness of a given bitstring by:
    - Extracting substrings using dependencies.
    - Converting each substring to a decimal index.
    - Looking up fitness values in the table.
    - Summing up all fitness contributions.
    """
    interactions = generate_interactions(N, K)  
    total_fitness = 0  

    for i in range(N):  
        indices = interactions[i]  
        substring = get_substring(bitstring, indices)  
        index = binary_to_decimal(substring)  
        fitness_value = lookup_tables[i][index]  
        total_fitness += fitness_value  
    
    return total_fitness  

def generate_all_genotypes(N):
    """
    Generates all possible bitstrings of length N.
    """
    all_genotypes = []
    for i in range(2 ** N):  
        binary_str = ""
        num = i
        for _ in range(N):  
            binary_str = str(num % 2) + binary_str
            num = num // 2
        while len(binary_str) < N:  
            binary_str = "0" + binary_str
        all_genotypes.append((i, binary_str))
    return all_genotypes  

def process_nk_landscape():
    """
    Processes the NK landscape input and prints:
    - The lookup table.
    - The genotype (as a decimal index).
    - Its computed fitness score.
    """
    N, K, lookup_tables = parse_input()  

    print("\nLookup Table:")
    print_lookup_table(N, K, lookup_tables)

    print("\nGenotype Fitness:")
    print("genotype,fitness")  
    all_genotypes = generate_all_genotypes(N)  

    for i, genotype in all_genotypes:
        fitness = calculate_fitness(genotype, N, K, lookup_tables)  
        print(i, ",", fitness, sep="")  

if __name__ == "__main__":
    process_nk_landscape()
