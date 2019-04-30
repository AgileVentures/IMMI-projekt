A Membership system for
the Sveriges Hundföretagare
(Swedish Dog Industry Association)
======================================================================================

This is a membership system for Sveriges Hundföretagare, a nation-wide organization in Sweden for ethical dog-associates.
[http://hitta.sverigeshundforetagare.se/](http://hitta.sverigeshundforetagare.se/)

The main project documentation is on the [page for this project at the AgileVentures site.](http://www.agileventures.org/projects/shf-project)

_This is a project of [AgileVentures](http://www.agileventures.org), a non-profit organization dedicated to crowdsourced learning and project development._  

Sempahore status: [![Build Status](https://semaphoreci.com/api/v1/shf-project/shf-project/branches/develop/shields_badge.svg)](https://semaphoreci.com/shf-project/shf-project)

Codeclimate: [![Code Climate](https://codeclimate.com/github/AgileVentures/shf-project/badges/gpa.svg)](https://codeclimate.com/github/AgileVentures/shf-project)

## Want to Help?  Here's How to Get Started and Some Info:

- Read the Requirements and Dependencies, and Installation sections below. Be sure to **read the [CONTRIBUTING](https://github.com/AgileVentures/shf-project/blob/develop/CONTRIBUTING.md) document.**  That describes how we work:  where and how we track user stories, issues, bugs, etc.  It describes how we work with GitHub, our style standards, general workflow, etc.  We do try to document things here in the GitHub wiki.  (And we always appreciate feedback on what we can improve.)

- We're often asked: _"The system is for people in Sweden.  Do I have to speak Swedish?"_

   Nope. The development takes place in English.  (So you do need to speak English.)
   The system uses Rails' I18n and so can be displayed in either Swedish or English.
   You don't have to be dog owner, either.


## Requirements and Dependencies

This project runs on a Ruby on Rails stack with postgreSQL as the repository.

- ruby - check Gemfile for current version (2.5.1 as of November, 2018)
- rails - check Gemfile for current version (5.2.1 as of November, 2018)
- Postgresql DB
- imagemagick https://www.imagemagick.org

Required for integration tests (cucumber + capybara):
- chromedriver 2.32.498537 or higher https://sites.google.com/a/chromium.org/chromedriver/downloads


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

1. Install required gems in your local environment - run this from the project
  home directory:

```shell
$ bundle install
```
2. Some of our cucumber tests use Google Chrome as the web browser (with selenium
  as the webdriver).  For that, you'll need to [download chromedriver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
  to your local machine.

3. Make sure you have the correct "locale" file present on your local machine -
  Since our user base primarily works in Swedish, we need to confirm that the
  database will correctly sort (collate) text in that language.

    a. Check if the Swedish local file is present on your machine:

    ```shell
    $ locale -a
    ```
    In the list of locale files, look for a file that looks like this: `sv_SE.UTF-8`.
    If found, then you're fine.  If not, do the next step.

    b. Load the swedish "language pack".  For instance, on Linux this should work:

    ```shell
    $ sudo apt-get install language-pack-sv
    ```

    Execute the previous step again and confirm that the language pack has been installed.

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

### Step 4: Set up the database
```shell
$ bundle exec rake shf:db_prep
$ bundle exec rake db:seed
```
The rake task `shf:db_prep` creates or recreates the development and test DBs, creates the application
schema, loads foundation data table (e.g. list of Swedish counties).
Then, run seed.db to populate the DB with data for development.

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
