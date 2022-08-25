import base64, re
import sys
import hmac
from Crypto.Cipher import AES
from Crypto.Util import Padding

key = sys.argv[1]  # 64 bytes
value = sys.argv[2]

# Base64 decode the response and convert to hex
hex_value = base64.b64decode(value).hex()


def decrypt(cipher_hex, key):
    # Extract the 32 bytes of the Hash signature from the end of the cipher_hex
    extract_hash = cipher_hex[-64:]

    # last 32 bytes of the 64 byte key used by the encrypt function (2 hex digits per byte)
    private_key = key[-64:]
    # IV & ciphertext
    content = cipher_hex[:-64]

    hash_text = hmac.new(key=bytes.fromhex(private_key), msg=(bytes.fromhex(content) + bytearray(8)),
                         digestmod='SHA512')

    # Calculated tag is only the the first 32 bytes of the resulting SHA512
    calculated_hash = hash_text.hexdigest()[:64]

    if extract_hash == calculated_hash:
        # first 32 bytes of the 64 byte key used by the encrypt function (2 hex digits per byte)
        private_key = bytes.fromhex(key[:64])

        # Extract the cipher text (remaining bytes in the middle)
        cipher_text = cipher_hex[32:]
        cipher_text = bytes.fromhex(cipher_text[:-64])

        # Extract the 16 bytes of initial vector from the beginning of the data
        iv = bytes.fromhex(cipher_hex[:32])

        # Decrypt
        cipher = AES.new(private_key, AES.MODE_CBC, iv)

        plain_pad = cipher.decrypt(cipher_text)
        unpadded = Padding.unpad(plain_pad, AES.block_size)

        return unpadded.decode('utf-8')
    else:
        return "Incorrect MAC"


decrypted_value = decrypt(hex_value, key)
print(decrypted_value)
