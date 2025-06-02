# Fuiz Dockerfile

## Usage

First create a `.env` file in the root directory of the project. 
Copy the `.env.example` file and rename it to `.env`.

```bash
cp .env.example .env
```

Then, open the `.env` file and modify the environment variables as needed.
You need to change the `AUTH_SECRET` variable, used by `Auth.js` to a random string for authentication purposes.
You can use the following command to generate a random string:

```bash
openssl rand -hex 32
```

Use the following command to build and run the Docker container, using the `.env` file created above:

```bash
docker build -t fuiz .
docker run --name fuiz --env-file .env -p 5173:5173 -p 8080:8080 -p 5040:5040 fuiz
```

Open your browser and go to `http://localhost:5173` to access the application.

## Development

