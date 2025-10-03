# E-Commerce Platform - Project Submission

- **Repository:** [https://github.com/daretechie/ecommerce-platform](https://github.com/daretechie/ecommerce-platform)
- **Author:** daretechie

This document provides all the necessary information for reviewing and grading the E-Commerce Platform project.

## 1. Project Overview

A full-stack e-commerce platform featuring a React frontend and Express.js API, fully containerized with Docker, and integrated with CI/CD pipelines. This project demonstrates modern software engineering practices, including DevOps, automated testing, and deployment-ready configurations.

### Features

- **Frontend (React)**: A responsive UI with product listings, product details, user login, and order placement.
- **Backend (Express.js)**: A RESTful API serving products, handling user authentication with JWT, and managing orders.
- **Containerization**: The entire application stack (frontend and backend) can be run easily with Docker Compose.
- **CI/CD**: GitHub Actions are configured to build, test, and publish Docker images automatically.

### Tech Stack

- **Frontend**: React, React Router, Axios
- **Backend**: Node.js, Express.js, JSON Web Token (JWT)
- **DevOps**: Docker, Docker Compose, GitHub Actions

## 2. How to Run the Project

For ease of review, the recommended method is to use Docker, as it encapsulates the entire environment.

### Using Docker (Recommended Method)

**Prerequisites:**

- Docker and Docker Compose must be installed.

**Steps:**

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/daretechie/ecommerce-platform.git
    cd ecommerce-platform
    ```

2.  **Set Environment Variables:**
    This project uses a secret key for signing authentication tokens. For local execution, you can set it directly in your shell.

    ```bash
    export JWT_SECRET=your_very_secret_key
    ```

3.  **Build and Run with Docker Compose:**
    This single command will build the Docker images for the API and the webapp, and start the containers.

    ```bash
    docker-compose up --build
    ```

4.  **Access the Application:**
    - **Frontend:** [http://localhost:3000](http://localhost:3000)
    - **API Health Check:** [http://localhost:3001/health](http://localhost:3001/health)

## 3. Evidence of Functionality (For Grading)

This section provides visual evidence of the application's features.

_(Please replace the bracketed text with your actual screenshots.)_

### 3.1. Home Page

![Home Page](screenshots/home.png)
**Description:** The home page displays a welcome message and featured products, demonstrating the basic rendering of the React frontend.

### 3.2. Product Listing Page

![Products Page](screenshots/products.png)
**Description:** This page fetches and displays a list of all available products from the backend API.

### 3.3. Product Detail Page

![Product Detail](screenshots/product-detail.png)
**Description:** Clicking on a product from the listing page navigates to its detailed view.

### 3.4. Login Page & Authentication

![Login Page](screenshots/login.png)
**Description:** The login page allows users to authenticate. Successful login provides a JWT token that is used for accessing protected routes.

### 3.5. Order Placement

![Order Placement](screenshots/order-placement.png)
**Description:** Once logged in, users can place orders. This demonstrates a protected API endpoint.

## 4. DevOps and CI/CD Evidence

### 4.1. Dockerization

The `docker-compose.yml` file orchestrates the `api` and `webapp` services.
![Docker Compose](screenshots/docker-compose.png)
**Description:** This shows that both the frontend and backend services are running in Docker containers as expected.

### 4.2. CI/CD Pipeline (GitHub Actions)

The `.github/workflows/ci.yml` file defines the Continuous Integration pipeline, which runs tests on every push and pull request.
![CI Workflow](screenshots/ci-workflow.png)
**Description:** This demonstrates that the automated build and test process is working correctly.

### 4.3. Continuous Delivery and Deployment

This project implements **Continuous Delivery**. The `docker-publish.yml` workflow automatically builds and pushes Docker images for the `api` and `webapp` to GitHub Container Registry (GHCR) on every push to the `main` branch.

This ensures that a production-ready artifact is always available.

![Docker Publish Workflow](screenshots/docker-publish.png)

**Description:** This demonstrates that the application is automatically packaged and published, ready for deployment. The final step of deploying to a cloud host (like AWS, Azure, or GCP) can be added to this workflow by including steps to pull the latest image from GHCR and run it on the cloud provider's infrastructure.

### 4.4. Performance Optimization (Caching)

To accelerate the build and test process, the CI workflow uses caching for dependencies. In the `.github/workflows/ci.yml` file, the `api` job is configured to cache the `npm` directory.

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm
```

![Cache Hit](screenshots/cache-hit.png)

**Description:** This shows the workflow leveraging cached dependencies to avoid re-downloading them on every run, which significantly reduces build times.

## 5. Testing

Unit tests have been set up for the backend API.

**To run the tests:**

```bash
cd api
npm install
npm test
```

![Test Results](screenshots/test-results.png)
**Description:** This shows the output of the automated tests, verifying the correctness of the API logic.

## 6. Troubleshooting Guide

If you encounter any issues, here are some common solutions:

- **Port Conflict:** If you get an error that port 3000 or 3001 is already in use, please stop the application that is using it. You can find the process using `sudo lsof -i :3000`.
- **`JWT_SECRET` not set:** If the API fails to start, ensure you have exported the `JWT_SECRET` environment variable in your terminal session before running `docker-compose up`.
- **Docker Issues:** Run `docker-compose logs -f` to see real-time logs from the containers. If something is failing, the logs will provide clues.
