# Arima #
---------

### How do I get set up? ###

* Ruby version
> 1.9.3+

* Install Homebrew
> `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

* Install RVM
> `\curl -sSL https://get.rvm.io | bash -s stable`

* Install Ruby 
> `rvm install 2.2.0 `

* Get commandline tools for Mac OSX
> `xcode-select --install`

* Install bundler gem and Install dependencies
> `gem install bundler`
> `bundle install`

* Configuration
> See files in `src/config`

* Start DB
> `pg_ctl -D /usr/local/var/postgres/ start`

* Configure local DB
> `createuser -s -r arima`

* Database setup
> Copy config/database.yml.example to config/database.yml and run
 `rake db:create db:migrate db:seed`

* Start Rails server
> `rails s`

* How to run the test suite
> `rake`

* Deployment instructions
> capistrano...

* Generate documentations
> `rake doc:app`

### Guidelines ###

* Writing tests
* Code review
* Other guidelines

### How do I use livereload?

1. In one terminal window do: bundle exec guard
2. In a second terminal window do: rails server

Why do we want this?
Because this gives an added benefit of watching the changes in the css, js and html(erb) files. If any of these file are modified and saved livereload will automatically refresh the browser and you can see the changes. Now thats cool!

###FAQ
1. Getting error message "Could not find guard-livereload-2.2.0 in any of the sources"
solution: Please do bundle install

2.LiveReload isn't working?
solution: Check if port 35729 is free. If the port is not free it follow the steps below before doing bundle exec guard again.

For MAC:
1. To check if port is free do : lsof -i :35729
2. To kill PID do: kill -9 <PID>
Visit the website live at http://arima.io
