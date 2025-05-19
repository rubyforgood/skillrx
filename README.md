# SkillRX
SkillRX is a Ruby on Rails content management application which will allow medical training providers to upload and manage content which will be delivered to Raspberry Pi and other computers in low-resource areas for use by medical professionals at these locations.

The project provides a ground-up rewrite of the [CMES Admin Panel](https://github.com/techieswithoutborders/cmes-admin-panel-next) for [Techies Without Borders](https://techieswithoutborders.us/).

> [CMES](https://cmesworld.org/) is an initiative of Techies without Borders, a global nonprofit focused on harnessing technology for social development. CMES aims to address the difficulty in accessing CME content for medical practitioners in resource-constrained areas of the world, a critical problem in public health. Since its inception in January 2016, the CMES team has distributed over 200 CMES thumb drives to medical doctors and nurses working at remote locations in Nepal, Uganda, Ecuador, Nigeria, St. Lucia and the Oceania region (Fiji,Tonga, Solomon Islands, Tuvalu, Samoa and Cook Islands).

# Ruby for Good
SkillRX is one of many projects initiated and run by Ruby for Good. You can find out more about Ruby for Good at https://rubyforgood.org.

# Welcome Contributors!
Thank you for checking out our work. We are in the process of setting up the repository, roadmap, values, and contribution guidelines for the project. We will be adding issues and putting out a call for contributions soon.

[Contribution guidelines for this project](CONTRIBUTING.md)


# Install & Setup

Clone the codebase 
```
git clone git@github.com:rubyforgood/skillrx.git
``` 

Run the setup script to prepare the DB and assets
```sh
bin/setup
```

To run the app locally, use:
```
bin/dev
```

To update dependencies in Gemfile, use:
```
bundle install
```

You should see the seed organization by going to:
```
http://localhost:3000/
```


# Running specs

```sh
# Default: Run all spec files (i.e., those matching spec/**/*_spec.rb)
$ bundle exec rspec

# Run all spec files in a single directory (recursively)
$ bundle exec rspec spec/models

# Run a single spec file
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb

# Run a single example from a spec file (by line number)
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb:8

# See all options for running specs
$ bundle exec rspec --help
```

# Setup

Clone this repo and run `bin/setup`. Run `bin/dev` or `bin/server` (if you like Overmind) to start working with app.

# Testing

This project uses:
* `rspec` for testing
* `shoulda-matchers` for expectations
* `factory_bot` for making records

To run tests, simply use `bin/rspec`. You can also use `bin/quality` to check for code style issues.

# Docker Development Environment

This project is containerised using Docker to ensure consistent development environments across the team.

## Prerequisites

- Docker Engine installed on your system
- Docker Compose V2 or later

## Initial Setup

1. Copy the environment configuration file:
   ```
   cp .env.example .env
   ```

2. Configure the environment variables in `.env` as needed. These variables set up the containerised services. Update the `.env.example` file with any new or changed variables.

3. To view the uploaded files from http://localstack:4566 in your browser, add the following line to your `/etc/hosts` to resolve `localstack` to your host system:
    ```
    127.0.0.1 	localstack
    ```

4. Build and start the containers:
    ```
    docker compose up
    ```

This will build the images and initialise the containers. You can exit and stop the containers using CTRL+C.

## Container Architecture
The development environment consists of three containerised services:

* app : Rails application service
    * Handles the main application logic
    * Runs on Ruby on Rails
* db : PostgreSQL database service
    * Persists application data 
    * Runs independently from the application
* localstack : AWS S3 emulator
     * Provides local S3-compatible storage
     * Enables development without actual AWS setup

## Development Workflow

We provide a Makefile to simplify common development tasks. Here are the most frequently used commands:
```
  make build             # Build image containers
  make start [service]   # Start all containers or a specific service
  make stop [service]    # Stop all containers or a specific service
  make shell             # Open a bash shell in the app container
  make console           # Start Rails console
  make test              # Run all tests
```

For a complete list of available commands:
```bash
make help
```

## Common Tasks
### Rebuilding the Environment
To completely rebuild your development environment:

```bash
make rebuild
```
This command will clean existing containers, rebuild images, and prepare the database.

### Viewing Logs
To monitor service logs:
```
make logs         # View all container logs
make logs app     # View only Rails application logs
```

### Container Management
Individual services can be managed using:
```
make start db     # Start only the database container
make stop app     # Stop only the application container
make restart db   # Restart only the database container
```

### Troubleshooting
If you encounter issues:
- Ensure all required ports are available on your system
- Verify that your .env file contains all necessary variables
- Try rebuilding the environment with make rebuild
- Check container logs for specific error messages
