import sys
from Crypto.Util import number
from Crypto.Random import random
sys.setrecursionlimit(500000)

B = [777777773, 1000000007, 1000000009, 998244353, 65537]

def generate_basis(n):
  res = 2
  while(1):
	tmp = next_prime(int(res[-1]))
	if tmp > n:
	  return res
	res.append(int(tmp))

B = generate_basis(64)
gamma = B

def is_prime(n):
  if n == 2: return True
  if n <= 1 or (not n&1): return False
  return all(miller_rabin_round(n, base) for base in gamma)

def miller_rabin_round(n, base):
  base %= n
  if base == 0: return True
  d = n-1
  r = 0
  while not d & 1:
    d >>= 1
    r += 1
  assert(n-1 == 2**r * d)
  
  x = pow(base, d, n)
  if x == 1 or x == n-1: return True
  for _ in range(r-1):
    x = x * x % n    
    if x == n-1: return True
  return False

def miller_rabin(n):  
  return all(miller_rabin_round(n,base) for base in B)

def factorize(n):
  factors = []
  p = 2
  while True:
    while(n % p == 0 and n > 0): #while we can divide by smaller number, do so
      factors.append(p)
      n = n // p
    p += 1  #p is not necessary prime, but n%p == 0 only for prime numbers
    if p > n // p:
      break
  if n > 1:
    factors.append(n)
  return factors

# https://martin-thoma.com/how-to-calculate-the-legendre-symbol/
def legendre(a, p):    
  if a >= p or a < 0:
    return legendre(a % p, p)
  elif a == 0 or a == 1:
    return a
  elif a == 2:
    if p%8 == 1 or p%8 == 7:
      return 1
    else:
      return -1
  elif a == p-1:
    if p%4 == 1:
      return 1
    else:
      return -1
  elif not is_prime(a):
    factors = factorize(a)
    product = 1
    for pi in factors:
      product *= legendre(pi, p)
    return product
  else:
    if ((p-1)//2)%2==0 or ((a-1)//2)%2==0:
      return legendre(p, a)
    else:
      return (-1)*legendre(p, a)


def get_even_divisor(factor):
  divisor = [2]
  for f in factor:
    p, e = f
    if p == 2: continue
    divisor += [d * p**a for d in divisor for a in range(1,e+1)]
  return divisor

def recover(S, st, en, idx):
  ret = 1
  for i in range(en-1, st-1, -1):
    if idx & 1: ret *= S[i]
    idx >>= 1
  return ret

# want to find subset of S which production is 1 mod m(upper n-bit)
def MITM(S, m, n):
  ret = []
#  print(S)
  k = len(S)//2
  table1 = [(1,0)]
  for i in range(k):
    table1 = [(elem[0], elem[1]<<1 | 0) for elem in table1] + [(elem[0]*S[i]%m, elem[1]<<1 | 1) for elem in table1]
  table1.pop(0)

  table2 = [(1,0)]
  for i in range(k+1,len(S)):
    table2 = [(elem[0], elem[1]<<1 | 0) for elem in table2] + [(elem[0]*S[i]%m, elem[1]<<1 | 1) for elem in table2]
  table2.pop(0)

  table2 = [(number.inverse(elem[0],m), elem[1]) for elem in table2]
  idx1,idx2 = 0,0
  table1.sort()
  table2.sort()
  idx1 = 0
  idx2 = 0
  while idx1 < len(table1) and idx2 < len(table2):
    if table1[idx1][0] < table2[idx2][0]:
      idx1 += 1
    elif table1[idx1][0] > table2[idx2][0]:
      idx2 += 1
    else:
      idx = (table1[idx1][1] << (len(S)-k)) | table2[idx2][1]
      val = recover(S,0,len(S),idx)
      if val.bit_length() >= n:
        factor = []
        for i in range(len(S)-1, -1, -1):
          if idx & 1: factor.append(S[i])
          idx >>= 1
        return val,factor
      idx1 += 1
      idx2 += 1
  return None, None

def generator():
  alpha = generate_basis(300);
  print(alpha)
  MFactor = ((2, 1), (3, 3), (5, 2))
  for i, x in enumerate(alpha):
	if(i <= 2):
	  continue
	else:
	  MFactor = MFactor + (x,1)

  print(MFactor)


  M = 1
  for f in Mfactor:
    M *= f[0]**f[1]

  divisor = get_even_divisor(Mfactor)
  divisor.sort()
  hash_table = [[] for _ in range(2**len(B))]      
  for d in divisor:
    if d.bit_length() > 40: break
    r = d+1
    if not is_prime(r): continue
    h = 0
    for base in B:
      l = legendre(base, r)
      if l == 0:
        h = -1
        break
      elif l == -1: h = (h<<1)
      else: h = (h<<1) | 1
    if h != -1:
      hash_table[h].append(r)

  for i in range(2**len(B)):
    print("hash table sz :", len(hash_table[i]))
    q, factors = MITM(hash_table[i][:50],M,512)
    if not q: continue
    if not miller_rabin(q):
      print("SOMETHING WRONG...")
      continue
    print("strong pseudoprime : {}".format(q))
    print(factors)        

generator()