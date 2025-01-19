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

# Enjoy!
```

## Requirements

REST API that enables users to:

1. Log in/Log out
2. Upload individual files, zip them and share download link to them with a password (can't be stored in db)
3. List uploaded files, with a links to their download

Things to consider:

1. How many files can be uploaded? Limit? Allow deleting them?

2. Where do we store the files?

3. Authentication? JWT, but what strategy is best here
