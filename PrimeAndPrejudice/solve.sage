import random
from socket import *

tmp = []
all_list = []
tmp_list = []
def miller_rabin(n, b):
    """
    Miller Rabin test testing over all
    prime basis < b
    """
    basis = generate_basis(b)
    if n == 2 or n == 3:
        return True

    if n % 2 == 0:
        return False

    r, s = 0, n - 1
    while s % 2 == 0:
        r += 1
        s //= 2
    for b in basis:
        x = pow(b, s, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True

def generate_basis(n):

    res = [2]
    while(1):
        tmp = next_prime(int(res[-1]))

        if tmp > n:
            return res
        res.append(int(tmp))

def crt(a, p):
    M = 1
    for i in range(len(p)):
        M *= p[i]
    ans = 0
    for i in range(len(p)):
        ans += a[i] * (M // p[i]) * inverse_mod(M//p[i], p[i]);
    return ans % M

primes = generate_basis(400)
prime_list = generate_basis(primes[-1] * 100)
S = []

for i in range(len(primes)):
    tmp = []
    for pr in prime_list:
        if pr <= primes[i]:
            continue
        res = kronecker(primes[i], pr)
        if res != -1:
            continue
        res2 = pr % (4*primes[i])
        try:
            tmp.index(res2)
        except:
            tmp.append(res2)
    tmp.sort()
    S.append(tmp)

flag = 0
for k1 in range(9, 600, 2):
    for k2 in range(k1 + 2, 600, 2):
        error_flag = 0
        if k1 in primes:
            break
        if k2 in primes:
            break
        k_list = [k1, k2]
        ans_list = []
        for i in range(len(primes)):
            tmp_list = [[] for _ in range(len(k_list))]
            for j in range(len(S[i])):
                for k in range(len(tmp_list)):
                    r = inverse_mod(k_list[k], 4 * primes[i]) * (S[i][j]+k_list[k] - 1)
                    r = r % (4 * primes[i])
                    tmp_list[k].append(r)
            ans = list(set(tmp_list[0]).intersection(tmp_list[1]))
            for j in range(2, len(k_list)):
                ans = list(set(ans).intersection(tmp_list[j]))
            ans = list(set(ans).intersection(S[i]))
            ans.sort()
            if(len(ans) == 0):
                print("error!")
                error_flag = 1
            ans_list.append(ans)
        if error_flag:
            continue
        a1 = inverse_mod(-1 * k_list[0], k_list[1])
        a2 = inverse_mod(-1 * k_list[1], k_list[0])
        p_set = [k_list[0], k_list[1], 8]
        a_set = [a2, a1, ans_list[0][0]]
        all_list = []
        for i in range(1, len(primes)):
            p_set.append(primes[i])
        c = ans_list[0][0] % 4
        for i in range(1, len(ans_list)):
            for j in range(len(ans_list[i])):
                if ans_list[i][j] % 4 == c:
                    a_set.append(ans_list[i][j] % primes[i])
                    break
        if len(a_set) != len(p_set):
            print("ERROR")
            error_flag = 1
        if error_flag:
            continue

        c_res = crt(a_set, p_set)
        n = 1
        for j in range(len(p_set)):
            n *= p_set[j]
        p1 = c_res + n

        for i in range(10000):
            if i % 1000 == 0:
                print(i)
            p2 = k_list[0] * (p1-1)+1
            p3 = k_list[1] * (p1-1)+1
        # print(p1, p2, p3)
        # and isPrime(p2) and isPrime(p3):
            if isPrime(p1):
                if isPrime(p2):
                    if isPrime(p3):
                        print("hooray")
                        flag = 1
                        break
            p1 += n

        if flag:
            answer = p1 * p2 * p3
            print("answer : " + str(answer))
            break
        print("Hmm")

    if flag:
        break
'''
def generatePrimeList(b): # Generate prime list!
    P = Primes()
    s = P.first(); a = []
    while(s <= b):
        a.append(s)
        s = P.next(s)
    return a

a = generatePrimeList(64)
S = []

for x in a: # Table 3 
    b = 4 * x
    p = []
    for k in range(b):
        if kronecker(x, k) == -1:
            p.append(k)
    s = []
    for k in p:
        if gcd(k, b) == 1:
            s.append(k)
    S.append(s)

h = 3
k_list = [1]
for i in range(1, 3): #  select ki
    for j in range(2, 237):
        isP = False
        for k in a:
            if gcd(j, k) != 1:
                isP = True
                break
        if isP == False and not j in k_list:
            k_list.append(j)
            break
        
subset = []

for i, l in enumerate(S): # Table 4
    b = 4 * a[i]
    l1 = set([])
    for j,k in enumerate(k_list):
        l2 = set([])
        k_inverse = inverse_mod(k, b)
        for s in l:
            l2.add(k_inverse * (s + k - 1) % b)
        if(j == 0):
            l1 = l2
        l1 = l1 & l2
    subset.append(sorted(l1))

a.append(8)
for i in range(1, len(k_list)):
    a.append(k_list[i])

table_list = [] 

for k in subset:
    table_list.append(k[random.randrange(0,len(k))])
table_list.append(3)

table_list.append(inverse_mod(-k_list[2], k_list[1]))
table_list.append(inverse_mod(-k_list[1], k_list[2]))
assert len(a) == len(table_list)

r = 1
for x in a:
    r *= x
print(r)
p = lcm(a) * 2
t = crt(table_list, a)

print(p)
print(t)

k = (2^200 - t) // p

while True:
    p1 = p * k + t
    k += 1
    if is_prime(p1) and (int(p1).bit_length() >= 200):
        p2 = k_list[1] * (p1 - 1) + 1
        p3 = k_list[2] * (p1 - 1) + 1
        if is_prime(p2) and is_prime(p3):
            N = p1 * p2 * p3
            sock = socket(AF_INET, SOCK_STREAM)
            sock.connect(('socket.cryptohack.org', 13385))
            print(sock.recv(1000))
            payload = b'{"base":25, "prime":' + str(N).encode() + b"}"
            print(payload)
            sock.send(payload)
            data = sock.recv(1000)
            print(data)
            if b"flag" in data:
                print(data)
                exit()
            else:
                sock.close()
'''