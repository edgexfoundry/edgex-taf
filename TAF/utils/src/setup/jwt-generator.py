import jwt
from datetime import datetime
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
import sys

issuer = sys.argv[1]
exp = sys.argv[2]
# Step 1: Generate RSA private key
key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048
)

# Serialize private key to PEM format
private_key_pem = key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.TraditionalOpenSSL,  # PKCS#1
    encryption_algorithm=serialization.NoEncryption()
)

# Get the public key
public_key_pem = key.public_key().public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
)

# Step 2: Prepare payload and headers
payload = {
    "iss": issuer,
    "exp": int(exp)  # Timestamp in seconds
}

headers = {
    "alg": "RS256",
    "typ": "JWT"
}

# Step 3: Encode JWT token
token = jwt.encode(
    payload,
    key,
    algorithm='RS256',
    headers=headers
)

# Step 4: Output
print("private_key:" + private_key_pem.decode() +
      "public_key:" + public_key_pem.decode() +
      "jwt_token:" + token)
