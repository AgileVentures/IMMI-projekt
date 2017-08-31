A Membership system for
the Sveriges Hundföretagare
(Swedish Dog Industry Association)
======================================================================================

This is a membership system for Sveriges Hundföretagare, a nation-wide organization in Sweden for ethical dog-associates.

The main project documentation is on the [page for this project at the AgileVentures site.](http://www.agileventures.org/projects/shf-project)

_This is a project of [AgileVentures](http://www.agileventures.org), a non-profit organization dedicated to crowdsourced learning and project development._  


Sempahore status: [![Build Status](https://semaphoreci.com/api/v1/lollypop27/shf-project/branches/develop/badge.svg)](https://semaphoreci.com/lollypop27/shf-project)

Codeclimate: [![Code Climate](https://codeclimate.com/github/AgileVentures/shf-project/badges/gpa.svg)](https://codeclimate.com/github/AgileVentures/shf-project)

## Requirements and Dependencies

This project runs on a Ruby on Rails stack with postgreSQL as the repository.

- ruby version - check Gemfile (2.4.1 as of July 04, 2017)
- rails 5.1.0 (5.1.0 as of July 04, 2017)
- Postgresql DB
- imagemagik https://www.imagemagick.org
- phantomjs (required for integration tests [cucumber tests]) http://phantomjs.org/

## Installation

### Step 1: Fork the repository

Forking the project creates a copy of the code base which you can modify without
affecting the main code base. Once you are satisfied with your changes, you can
make a pull request to the main repository.

Visit the project homepage on GitHub at:
<https://github.com/AgileVentures/shf-project>

Fork the project by clicking the Fork button on the top-right hand corner.

Now that you have a fork of the project, copy the URL for the repository
(just below the sidebar on the right) and clone the forked project using Git:
```shell
$ cd to/some/directory
$ git clone https://github.com/<your-github-username>/shf-project.git
```
This will create a directory (under the directory where you are currently)
called `shf-project`.  That is the "home" directory for the app.

You also need to configure a remote repo to point to the main project
repository in order to get latest updates. (This will be required at a later
  stage when submitting your features)

```shell
$ cd shf-project
$ git remote add upstream https://github.com/AgileVentures/shf-project
```

### Step 2: Install Project dependencies

```shell
$ bundle install
```
Some of our cucumber tests use Google Chrome as the web browser (with selenium
  as the webdriver).  For that, you'll need to [download chromedriver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
  to your local machine. 

### Step 3: Get "super secret" data

Sensitive or secret information (e.g. Google map API key) is maintained in this
file in the project home directory:
```
.env
```
That file will not be present in the environment when you first clone it because
it is not maintained in git - and thus is not pulled down from github. Contact
one of the project members to get the contents of that file (for example via
private message in Slack, or general message in the project's Slack channel).

### Step 4: Update the database
```shell
$ bundle exec rake shf:db_recreate
```
The rake task `db_recreate` creates the development DB, creates the application
schema, loads foundation data table (e.g. list of Swedish counties) and then
runs seed.db to populate the DB with data for development.

When this completes, initialize the test DB:
```shell
$ bundle exec rake db:test:prepare
```

### Step 5: Run the tests

```shell
$ bundle exec rspec
$ bundle exec rake cucumber
```
Discuss any errors with the team.

### Step 6. Start the server

```shell
$ bundle exec rails s
```
Point your browser to `localhost:3000` and confirm that the website is running.

### Step 7. Get access to Pivotal Tracker
We use Pivotal Tracker (PT) for bug and story tracking.  Please contact a
project team member (via Slack) to be added to our story board on PT.

## Contributing:

Please see our github [wiki](https://github.com/AgileVentures/shf-project/wiki)
for articles about contributing to the project.

## Problems?

If have any problems, please  **[search through the issues](https://github.com/AgileVentures/shf-project/issues) first** to see if it's already been addressed. If you do not find an existing issue, then open a new issue.
Please describe the problem in detail including information about your operating system (platforms), version, etc.  The more detail you can provide, the sooner we can address it.

## License

The authors and contributors have agreed to license all other software
under the MIT license, an open source free software license. See the
file named COPYING which includes a disclaimer of warranty.
