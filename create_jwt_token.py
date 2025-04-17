import jwt
import time
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

# Данные для создания JWT-токена
service_account_id = "aje2tcoa7g104235b9cc"
key_id = "ajev9hg01rrpsto6f8ch"  # Убедитесь, что это правильный ID ключа
private_key_path = "/home/alexander/diplom/private_key.pem"

# Создание JWT-токена
def create_jwt_token(service_account_id, key_id, private_key_path):
    try:
        with open(private_key_path, "rb") as key_file:
            private_key = serialization.load_pem_private_key(
                key_file.read(),
                password=None,
                backend=default_backend()
            )
    except ValueError as e:
        print(f"Ошибка при загрузке ключа: {e}")
        return None

    payload = {
        "aud": "https://iam.api.cloud.yandex.net/iam/v1/tokens",
        "iss": service_account_id,
        "iat": int(time.time()),
        "exp": int(time.time()) + 3600  # Время жизни токена (1 час)
    }

    try:
        jwt_token = jwt.encode(
            payload,
            private_key,
            algorithm="PS256",
            headers={"kid": key_id}
        )
    except jwt.exceptions.InvalidKeyError as e:
        print(f"Ошибка при создании JWT-токена: {e}")
        return None

    return jwt_token

# Создание токена и вывод результата
jwt_token = create_jwt_token(service_account_id, key_id, private_key_path)
if jwt_token:
    print(jwt_token)
