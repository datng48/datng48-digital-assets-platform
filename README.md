# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Digital Assets Platform

## Database Setup

1. Copy the database configuration template:
```bash
cp config/database.yml.example config/database.yml
```

2. Update `config/database.yml` with your PostgreSQL credentials:
```yaml
default: &default
  username: your_username
  password: your_password
```

3. Create and setup the database:
```bash
rails db:create
rails db:migrate
```

Note: Make sure PostgreSQL is installed and running on your system.
