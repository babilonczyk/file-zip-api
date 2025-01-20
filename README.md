# README

## Installation

```sh
# Install mysql & start service
brew install mysql
brew services start mysql

# Mysql service should be running
brew services list

# Enter project directory & install dependencies
bundle

# If mysql2 gem can't be installed due to unknown path, install it individually and later run bunle again
gem uninstall mysql2
gem install mysql2 -- --with-ldflags=-L/opt/homebrew/lib
bundle

# Create local db
bin/rails db:create

# Enjoy!
rails s
```

## Docs

```sh
rails s

# localhost:3000/api/v1/docs
```
