import pygame
import genotype_fitness_calc as nk  
import math
import sys
from helper_funcs import *

class NKLandscape:
  def __init__(self, filename=None):
    if filename is None:
      self.N, self.K, self.lookup_table = nk.parse_input()
    else:
      self.load_file(filename)

  def load_file(self, filename):
    self.input_file = filename
    lines = []
    with open(filename, 'r') as in_fp:
      for line in in_fp:
        line = line.strip()
        if line != '' and line[0] != '#':
          lines.append(line)
    lines.append('') # Determines EOF by empty line
    print(lines)
    self.N, self.K, self.lookup_table = nk.parse_input(lines)


  def print_table(self):
    nk.print_lookup_table(self.N, self.K, self.lookup_table)

  def calc_fitness(self, n):
    bin_str = self.dec_to_binary_string(n)
    return nk.calculate_fitness(bin_str, self.N, self.K, self.lookup_table)

  def dec_to_binary_string(self, n):
    bin_str = bin(n)[2:] #bin prepends a 0b that we want to get rid of
    if len(bin_str) < self.N: # Zero pad as needed
      bin_str = '0' * (self.N - len(bin_str)) + bin_str
    return bin_str

class Node:
  def __init__(self, x, y, bitstring, fitness):
    self.x = x
    self.y = y
    self.bitstring = bitstring
    self.num_ones = self.bitstring.count('1')
    self.fitness = fitness
    self.neighbors = [] 
    self.neighbor_line_colors = [] 

  def get_pos(self):
    return (self.x, self.y)

class VisualizedNKLandscape(NKLandscape):
  def __init__(self, screen_res, filename=None):
    super().__init__(filename)
    if not pygame.get_init():
      pygame.init()
    self.screen_res = screen_res
    self.screen = pygame.display.set_mode(self.screen_res)
    self.font = pygame.font.SysFont('ubuntu', 10)
    self.clock = pygame.time.Clock()
    # Node variables
    self.nodes = None
    self.needs_regen = True
    self.needs_change_handled = False
    # Render state variables
    self.needs_refresh = True
    self.draw_node_color = True
    self.draw_line_color = True
    self.draw_bitstrings = True
    self.draw_fitness = True
    self.draw_index = False
    # Other render variables
    self.node_radius = 10
    self.node_color_min = (255,0,0)
    self.node_color_max = (0,0,255)
    self.line_color_min = (255,0,0)
    self.line_color_max = (0,255,0)
    self.line_max_threshold = 2
    self.line_min_threshold = 0.5
  
  def regen_nodes(self):
    self.nodes = []
    col_counts = {} # How many nodes are _currently_ in each column?
    row_steps = [0] * (self.N + 1)
    for n in range(self.N + 1):
      col_counts[n] = 0
      max_col_nodes = n_choose_k(self.N, n)
      row_steps[n] = self.screen_res[1] / (max_col_nodes + 1)
    num_cols = self.N
    col_width = self.screen_res[0] / (num_cols + 2)

    min_fitness = None
    max_fitness = None
    max_abs_diff = 0
    for node_idx in range(2**self.N):
      fitness = self.calc_fitness(node_idx)
      print(node_idx, fitness)
      if min_fitness is None or fitness < min_fitness:
        min_fitness = fitness
      if max_fitness is None or fitness > max_fitness:
        max_fitness = fitness
      node = Node(0, 0, self.dec_to_binary_string(node_idx), fitness)
      node.x = int(col_width + node.num_ones * col_width)
      node.y = int(row_steps[node.num_ones] * (col_counts[node.num_ones] + 1))
      col_counts[node.num_ones] += 1
      base_val = 2**(self.N + 1) - 1 # bitstring of all 1s
      for n in range(self.N):
        mask = base_val ^ (1 << n)
        if node_idx & mask != node_idx:
          neighbor = self.nodes[node_idx & mask]
          node.neighbors.append(neighbor)
          max_abs_diff = max(max_abs_diff, abs(node.fitness - neighbor.fitness))
      self.nodes.append(node)
    # Color nodes after min/max fitness has been found
    if max_fitness == 0:
      print('Cannot calc colors because max fitness is 0 (will divide by zero)')
      self.draw_node_color = False
      self.draw_line_color = False
      self.needs_regen = False
      return
    for node in self.nodes:
      fit_frac = (node.fitness - min_fitness) / (max_fitness - min_fitness)
      node.color = interpolate_color(fit_frac, self.node_color_min, self.node_color_max)
      for neighbor in node.neighbors:
        diff = node.fitness - neighbor.fitness
        frac = abs(diff) / max_abs_diff
        color = (255,255,255)
        if diff < 0:
          color = interpolate_color(frac, (255,255,255), self.line_color_min)
        if diff > 0:
          color = interpolate_color(frac, (255,255,255), self.line_color_max)
        node.neighbor_line_colors.append(color)
    self.needs_regen = False

  def run(self):
    self.is_running = True
    while self.is_running:
      self.handle_input()
      if self.needs_change_handled:
        self.handle_value_change()
      if self.needs_regen:
        self.regen_nodes()
      self.render()
      self.clock.tick(60)

  def long_print(self):
    print('N=' + str(self.N))
    print('K=' + str(self.K))
    for row in self.lookup_table:
      for col in row:
        print(col)
 
  def handle_input(self):
    for evt in pygame.event.get():
      if evt.type == pygame.QUIT:
        self.is_running = False
      elif evt.type == pygame.KEYDOWN:
        if evt.key == pygame.K_ESCAPE or evt.key == pygame.K_q:
          self.is_running = False
        elif evt.key == pygame.K_b:
          self.draw_bitstrings = not self.draw_bitstrings
          self.draw_index = False
          self.needs_refresh = True
        elif evt.key == pygame.K_f:
          self.draw_fitness = not self.draw_fitness
          self.needs_refresh = True
        elif evt.key == pygame.K_n:
          self.draw_node_color = not self.draw_node_color
          self.needs_refresh = True
        elif evt.key == pygame.K_l:
          self.draw_line_color = not self.draw_line_color
          self.needs_refresh = True
        elif evt.key == pygame.K_s:
          self.needs_change_handled = True
        elif evt.key == pygame.K_p:
          self.long_print()
        elif evt.key == pygame.K_i:
          self.draw_index = not self.draw_index
          self.draw_bitstrings = False
          self.needs_refresh = True
  
  def handle_value_change(self):
    self.needs_regen = True
    self.needs_refresh = True
    self.needs_change_handled = False
    print('Format: row col value [s]')
    print('(row and col should be the integer index (0-based))')
    print('(the s is optional and will retrigger this prompt)')
    line = input()
    parts = line.strip().split()
    if len(parts) != 3 and not (len(parts) == 4 and parts[3] == 's'):
      print('Error! Expecting three numbers. Aborting change')
      print('The only alternative is for a fourth parameter, s')
      return
    row = int(parts[0])
    col = int(parts[1])
    new_val = float(parts[2])
    self.lookup_table[row][col] = new_val
    if len(parts) == 4 and parts[3] == 's':
      self.needs_change_handled = True
    self.print_table()

  def render_nodes(self):
    for node in self.nodes:
      for neighbor_idx, neighbor in enumerate(node.neighbors):
        color = (150,150,150)
        if self.draw_line_color:
          color = node.neighbor_line_colors[neighbor_idx]
        pygame.draw.line(self.screen, color, node.get_pos(), neighbor.get_pos(), 1)
    for node in self.nodes:
      color = (255,255,255)
      if self.draw_node_color:
        color = node.color
      pygame.draw.circle(self.screen, color, node.get_pos(), self.node_radius)
      if self.draw_bitstrings:
        surf = self.font.render(node.bitstring, True, (255,255,255))
        rect = surf.get_rect()
        rect.center = (node.x, int(node.y - self.node_radius * 1.5))
        self.screen.blit(surf, rect)
      if self.draw_index:
        index = int(node.bitstring, 2)
        surf = self.font.render(str(index), True, (255,255,255))
        rect = surf.get_rect()
        rect.center = (node.x, int(node.y - self.node_radius * 1.5))
        self.screen.blit(surf, rect)
      if self.draw_fitness:
        surf = self.font.render(str(round(node.fitness, 2)), True, (255,255,255))
        rect = surf.get_rect()
        rect.center = (node.x, int(node.y + self.node_radius * 1.5))
        self.screen.blit(surf, rect)

  def render_repeated_lines(self, lines, start_pos, pos_step):
    start_pos = list(start_pos)
    for line in lines:
      surf = self.font.render(line, True, (255,255,255))
      rect = surf.get_rect()
      rect.bottomleft = start_pos
      self.screen.blit(surf, rect)
      start_pos[0] += pos_step[0]
      start_pos[1] += pos_step[1]

  def render_controls(self):
    self.render_repeated_lines([
      'n to toggle node color', 
      'l to toggle line color', 
      'b to toggle node bitstrings',
      'n to toggle node fitnesses',
      's to change a value in the table',
      'p to print table'
      ], (0, self.screen_res[1]), (0, -12))

  def render(self):
    if self.needs_refresh:
      self.screen.fill((0,0,0))
      if self.nodes is None:
        self.regen_nodes()
      self.render_nodes()
      self.render_controls()
      pygame.display.flip()
      self.needs_refresh = False

filename = None
if len(sys.argv) > 1:
  filename = sys.argv[1]
landscape = VisualizedNKLandscape([1200,800], filename)
landscape.print_table()
landscape.run()



