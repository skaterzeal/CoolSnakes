import os
import sys
import base64
from pathlib import Path

OUTPUT_DIR = Path("ios_signing")
KEY_PATH = OUTPUT_DIR / "coolsnakes_key.pem"
CSR_PATH = OUTPUT_DIR / "CoolSnakes.certSigningRequest"
CER_PATH = OUTPUT_DIR / "distribution.cer"
P12_PATH = OUTPUT_DIR / "coolsnakes.p12"
B64_PATH = OUTPUT_DIR / "apple_certificate_base64.txt"
PASSWORD = b"coolsnakes123"

def step1_generate_csr():
    from cryptography.hazmat.primitives.asymmetric import rsa
    from cryptography.hazmat.primitives import hashes, serialization
    from cryptography import x509
    from cryptography.x509.oid import NameOID

    OUTPUT_DIR.mkdir(exist_ok=True)
    
    if not KEY_PATH.exists():
        print("Generating 2048-bit RSA Private Key...")
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        with open(KEY_PATH, "wb") as f:
            f.write(private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()
            ))
        print(f"Created private key: {KEY_PATH}")
    else:
        with open(KEY_PATH, "rb") as f:
            private_key = serialization.load_pem_private_key(f.read(), password=None)

    print("Generating Certificate Signing Request (CSR)...")
    csr = x509.CertificateSigningRequestBuilder().subject_name(x509.Name([        x509.NameAttribute(NameOID.COMMON_NAME, "Umur Kaya"),
        x509.NameAttribute(NameOID.EMAIL_ADDRESS, "developer@coolsnakes.app"),
        x509.NameAttribute(NameOID.COUNTRY_NAME, "TR"),
    ])).sign(private_key, hashes.SHA256())

    with open(CSR_PATH, "wb") as f:
        f.write(csr.public_bytes(serialization.Encoding.PEM))

    print(f"CSR saved: {CSR_PATH.resolve()}")

def step2_generate_p12():
    from cryptography.hazmat.primitives import serialization
    from cryptography import x509
    from cryptography.hazmat.primitives.serialization import pkcs12, BestAvailableEncryption

    cer_file = CER_PATH
    if not cer_file.exists():
        if Path("distribution.cer").exists():
            cer_file = Path("distribution.cer")
        elif Path("ios/distribution.cer").exists():
            cer_file = Path("ios/distribution.cer")
        else:
            return False

    with open(KEY_PATH, "rb") as f:
        private_key = serialization.load_pem_private_key(f.read(), password=None)

    with open(cer_file, "rb") as f:
        cer_data = f.read()

    try:
        cert = x509.load_der_x509_certificate(cer_data)
    except Exception:
        cert = x509.load_pem_x509_certificate(cer_data)

    print("Packaging certificate and private key into PKCS12 (.p12) with macOS Keychain compatibility...")
    encryption = (
        serialization.PrivateFormat.PKCS12.encryption_builder()
        .kdf_rounds(50000)
        .key_cert_algorithm(pkcs12.PBES.PBESv1SHA1And3KeyTripleDESCBC)
        .hmac_hash(hashes.SHA1())
        .build(PASSWORD)
    )

    p12_data = pkcs12.serialize_key_and_certificates(
        b"Apple Distribution: Umur Kaya (44BXDJ2366)",
        private_key,
        cert,
        None,
        encryption
    )

    with open(P12_PATH, "wb") as f:
        fewrite = f.write(p12_data)
    print(f"P12 file created: {P12_PATH}")

    b64_str = base64.b64encode(p12_data).decode("utf-8")
    with open(B64_PATH, "w", encoding="utf-8") as f:
        f.write(b64_str)
    print(f"Base64 saved: {B64_PATH}")
    return True

if __name__ == "__main__":
    if CER_PATH.exists() or Path("distribution.cer").exists():
        step2_generate_p12()
    else:
        step1_generate_csr()
