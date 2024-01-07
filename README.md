# Deploying an LLM on AWS Lambda

This repository contains code and instructions for deploying a smaller open-source Language Large Model (LLM) on AWS Lambda, using Python, Docker. The model used for demonstration is Phi-2 from Microsoft. This project aims to demonstrate how to use serverless infrastructure for LLM inference, particularly for applications requiring processing of sensitive data or specialized tasks.

## Project Overview

The project involves deploying the Microsoft Phi-2 model, a 2.7 billion parameter LLM, on AWS Lambda using Docker. It demonstrates creating an HTTP REST endpoint through Lambda's URL mechanism to provide LLM outputs with execution details.

### Detailed Guide
For a step-by-step tutorial, refer to the article: [How to deploy an LLM on AWS Lambda?](https://horosin.com/deploy-a-language-model-llm-on-aws-lambda)
### Key Features
- Utilizes the Phi-2 model from Microsoft.
- Implements docker-based AWS Lambda functions.
- Demonstrates the use of the `llama-cpp-python` package for LLM inference.

## Prerequisites for the tutorial
- Basic knowledge of programming, Docker, AWS, and Python.
- AWS account with AWS CLI installed and configured.
- Docker installed on your machine.
- A preferred IDE, such as Visual Studio Code.

## Getting Started
Clone this repository to get started with deploying your own LLM on AWS Lambda. Follow the instructions provided in the tutorial to set up your environment, run a containerized LLM locally, and deploy it to AWS Lambda.


## Social Media and Contact
Stay updated and reach out through the following channels:
- **Newsletter**: [Subscribe here](https://horosin.com/newsletter)
- **Twitter**: [@horosin_](https://twitter.com/horosin_)
- **LinkedIn**: [Profile](https://www.linkedin.com/in/horosin/)

Feel free to contribute to this repository, raise issues, or suggest improvements. Your feedback and contributions are highly appreciated!
