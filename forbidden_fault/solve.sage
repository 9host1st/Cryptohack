
from Crypto.Util.number import long_to_bytes as l2b
from Crypto.Util.number import bytes_to_long as b2l
def bitwiseXor(a, b):
    return bytes([(x ^^ y) for x, y in zip(a, b)])

F = GF(2**128, names='a')
(a,) = F._first_ngens(1)
R = PolynomialRing(F, names='X')
(X,) = R._first_ngens(1)

def block_to_poly(block):
    global F
    f = 0
    for e, bit in enumerate(bin(block).replace('0b','').rjust(128,'0')):
        f += int(bit) * a**e
    return f

def poly_to_int(poly):
    a = 0
    for i, bit in enumerate(poly._vector_()):
        a |= int(bit) << (127 - i)
    return a

def make_bytes_to_poly(msg):
    pad_cnt = (16 - len(msg))%16
    msg += '\x00' * pad_cnt
    return [block_to_poly(b2l(msg[i*16:(i+1)*16])) for i in range(len(msg)/16)]
    
enc1 = {"associated_data":"43727970746f4861636b","ciphertext":"6b8a8cf4c619fd8c4d53bf665ef6c561","nonce":"0a2f51c5d26bb462d935d7d3","tag":"a7a26a9b42642b7e26f68dcf440d8cba"}
enc2 = {"associated_data":"43727970746f4861636b","ciphertext":"68898ff7c51afe8f4e50bc655df5c662","nonce":"0a2f51c5d26bb462d935d7d3","tag":"b5e7e1a481c6728936b67a7b61a93923"}
enc3 = {"associated_data":"43727970746f4861636b","ciphertext":"69888ef6c41bff8e4f51bd645cf4c763","nonce":"0a2f51c5d26bb462d935d7d3","tag":"05db674e3f5845dbc689d7177d3555ab"}

nonce = enc1["nonce"]
t1,t2,t3 = enc1["tag"],enc2["tag"],enc3["tag"]
c1,c2,c3 = enc1["ciphertext"], enc2["ciphertext"], enc3["ciphertext"]

p1 = bytes.fromhex("61616161616161616161616161616161")
p2 = b"give me the flag"

xorP1P2 = bitwiseXor(p1, p2)

flagEnc = (bitwiseXor(xorP1P2, bytes.fromhex(c1)))

print(flagEnc.hex())
print(bitwiseXor(t1,))