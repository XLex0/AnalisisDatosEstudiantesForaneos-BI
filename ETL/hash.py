import os
import hashlib
from dotenv import load_dotenv  

# Cargar variables del .env solo una vez
load_dotenv()

SALT = os.getenv("HASH_SALT")
if SALT is None:
    raise RuntimeError("No se encontró la variable de entorno HASH_SALT")

def generar_hash(identificador: str) -> str:
    if identificador is None:
        return None
    texto = f"{identificador}{SALT}"
    return hashlib.sha256(texto.encode("utf-8")).hexdigest()
