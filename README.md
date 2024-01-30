# Backend Dev Challenge

## Tabla de contenido

+ [Descripción del proyecto](#descripción-del-proyecto)
+ [Requerimientos](#requerimientos)
+ [Uso](#uso)
+ [Desarrollo](#desarrollo)
+ [Documentación](#documentación)


## Descripción del proyecto

Este repositorio contiene el código fuente de la API REST desarrollada para el challenge *FUDO*.

El servidor web fue desarrollado en **Ruby** con el framework *Sinatra*, y utiliza una base de datos **PostgreSQL**.

Ambos servicios se ejecutan en contenedores **Docker**.

Para la autenticación de los usuarios se utilizó el estándar JSON Web Token (**JWT**).

## Requerimientos

Para poder ejecutar el proyecto se requiere tener instalado previamente:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Uso

Para ejecutar tanto el servidor web como la base de datos, se debe correr el siguiente comando:

```
docker compose up
```
Con el flag ```--build``` si es que se quiere reconstruir la imagen de la aplicación (por ejemplo si se añaden nuevas gemas).

En el caso de que haya colisiones con los puertos de otras aplicaciones, se pueden cambiar los mismos en ```docker-compose.yml```.

Y para detener la ejecución:

```
docker compose down
``` 
con el flag ```-v``` si es que se quiere eliminar el volumen de la base de datos.

## Desarrollo

Para ejecutar cualquiera de estos comandos, es necesario tener primero los servicios de la aplicación corriendo.

### *Tests*

Se utilizaron tests unitarios y de integración para probar el correcto funcionamiento de la aplicación.

```
docker compose exec webapp bundle exec rspec -fd
```

### *RuboCop*

Heramienta de análisis de código estático para la verificación de la guía de estilo de Ruby.

```
docker compose exec webapp bundle exec rubocop
```

### *Migraciones*

Para generar una nueva, primero se debe crear manualmente el archivo de migración en la carpeta ```db/migrate```.

Luego para migrar hasta la última versión:

```
docker compose exec webapp bundle exec rake db:migrate
```

## Documentación

*NOTA: La aplicación fue desarrollada en inglés en su totalidad, por la costumbre de programar en ese idioma.*

A continuación se pueden encontrar las definiciones de los distintos endpoints:

**Create User**
----
  _Endpoint to create a new user._

* **URL**

  `/users`

* **Method:**
  
  `POST`
  
*  **URL Params**

   **Required:**
 
   `None`

* **Data Params**

   **Required:**
 
   `email=[string]`  
   `password=[string]`

* **Success Response:**
  
  * **Code:** 201 <br />
    **Content:** 
    ```json
    { 
      "user": { 
        "id": 12,
        "email": "example@example.com",
        "crypted_password": "hashed_password_here"
      } 
    }
    ```
 
* **Error Response:**

  * **Code:** 400 BAD REQUEST <br />
    **Content:** 
    ```json
    { 
      "error": "Validation failed: Email can't be blank" 
    }
    ```
    ```json
    { 
      "error": "Validation failed: Crypted password can't be blank" 
    }
    ```
    If body is not json, or is missing parameters:
    ```json
    { 
      "error": "Must provide valid body" 
    }
    ```
    ```json
    { 
      "error": "Missing body parameter: email" 
    }
    ```
    ```json
    { 
      "error": "Missing body parameter: password" 
    }
    ```
  
  * **Code:** 409 CONFLICT <br />
    **Content:** 
    ```json
    { 
      "error": "User already exists!" 
    }
    ```
* **Sample Call:**
```bash
    curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"email": "example@example.com", "password": "password123"}' \
    http://localhost:4567/users
 ```
* **Notes:**
To generate a valid token, it is necessary to register the user first (authorization purposes)

**Generate Token**
----
  _Endpoint to generate authentication token._

* **URL**

  `/auth/token`

* **Method:**
  
  `POST`
  
*  **URL Params**

   **Required:**
 
   `None`

* **Data Params**

   **Required:**
 
   `email=[string]`  
   `password=[string]`

* **Success Response:**
  
  * **Code:** 201 <br />
    **Content:** 
    ```json
    { 
      "token": "generated_token_here"
    }
    ```
 
* **Error Response:**

  * **Code:** 400 BAD REQUEST <br />
    **Content:** 
    ```json
    { 
      "error": "Must provide valid body" 
    }
    ```
    ```json
    { 
      "error": "Missing body parameter: email" 
    }
    ```
    ```json
    { 
      "error": "Missing body parameter: password" 
    }
    ```

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** 
    ```json
    { 
      "error": "User not found!" 
    }
    ```
  
  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** 
    ```json
    { 
      "error": "Password is incorrect!" 
    }
    ```
* **Sample Call:**
  ```bash
    curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"email": "example@example.com", "password": "password123"}' \
    http://localhost:4567/auth/token
  ```

 * **Notes:**
    The token generated is used in the `POST` and `GET` to `/products` and is valid for 15 minutes.

**Create Product**
----
  _Endpoint to create a new product._

* **URL**

  `/products`

* **Method:**
  
  `POST`
  
*  **URL Params**

   **Required:**
 
   `None`

* **Data Params**

   **Required:**
 
   `name=[string]`
  
* **Headers**

   **Required:**

  `Authorization = Bearer <your_generated_token_here>`

* **Success Response:**
  
  * **Code:** 201 <br />
    **Content:** 
    ```json
    { 
      "product": { 
        "id": 1,
        "name": "Product Name"
      } 
    }
    ```
 
* **Error Response:**

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** 
    ```json
    { 
      "error": "Not authorized, provide valid JWT" 
    }
    ```
  
  * **Code:** 400 BAD REQUEST <br />
    **Content:** 
    ```json
    { 
      "error": "Validation failed: Name can't be blank" 
    }
    ```
     ```json
    { 
      "error": "Must provide valid body" 
    }
    ```
    ```json
    { 
      "error": "Missing body parameter: name" 
    }
    ```
* **Sample Call:**
  ```bash
    curl -X POST \
    -H "Authorization: Bearer your_generated_token_here" \
    -H "Content-Type: application/json" \
    -d '{"name": "Orange"}' \
    http://localhost:4567/products
  ```
* **Notes:**
    If the product name already exists, it updates it.
  

**Get Products**
----
  _Endpoint to retrieve all products._

* **URL**

  `/products`

* **Method:**
  
  `GET`
  
*  **URL Params**

   **Required:**
 
   `None`
* **Headers**

   **Required:**

  `Authorization = Bearer <your_generated_token_here>`

* **Success Response:**
  
  * **Code:** 200 <br />
    **Content:** 
    ```json
    { 
      "products": [
        { "id": 1, "name": "Product Name" },
        { "id": 2, "name": "Another Product" }
      ]
    }
    ```

* **Error Response:**

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** 
    ```json
    { 
      "error": "Not authorized, provide valid JWT" 
    }
    ```
* **Sample Call:**
  ```bash
    curl -X GET \
    -H "Authorization: Bearer your_generated_token_here" \
    http://localhost:4567/products
  ```

### Token

El token generado puede ser examinado en [jwt.io](https://jwt.io/), permitiendo ver la información del usuario y la fecha de expiración.

  

