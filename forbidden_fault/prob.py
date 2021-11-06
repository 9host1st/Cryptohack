from Crypto.Cipher import AES
import os

IV = ?
KEY = ?
FLAG = ?

@chal.route('/forbidden_fruit/decrypt/<nonce>/<ciphertext>/<tag>/<associated_data>/')
def decrypt(nonce, ciphertext, tag, associated_data):
    ciphertext = bytes.fromhex(ciphertext)
    tag = bytes.fromhex(tag)
    header = bytes.fromhex(associated_data)
    nonce = bytes.fromhex(nonce)

    if header != b'CryptoHack':
        return {"error": "Don't understand this message type"}

    cipher = AES.new(KEY, AES.MODE_GCM, nonce=nonce)
    encrypted = cipher.update(header)
    try:
        decrypted = cipher.decrypt_and_verify(ciphertext, tag)
    except ValueError as e:
        return {"error": "Invalid authentication tag"}

    if b'give me the flag' in decrypted:
        return {"plaintext": FLAG.encode().hex()}

    return {"plaintext": decrypted.hex()}

@chal.route('/forbidden_fruit/encrypt/<plaintext>/')
def encrypt(plaintext):
    plaintext = bytes.fromhex(plaintext)
    header = b"CryptoHack"

    cipher = AES.new(KEY, AES.MODE_GCM, nonce=IV)
    encrypted = cipher.update(header)
    ciphertext, tag = cipher.encrypt_and_digest(plaintext)

    if b'flag' in plaintext:
        return {
            "error": "Invalid plaintext, not authenticating",
            "ciphertext": ciphertext.hex(),
        }

    return {
        "nonce": IV.hex(),
        "ciphertext": ciphertext.hex(),
        "tag": tag.hex(),
        "associated_data": header.hex(),
    }