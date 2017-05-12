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

- ruby v. xxx _(TODO)_
- rails >= v. 5.0.0
- postgreSQL >=  v. _(TODO what is the minimum version of postgres?)_
   - see the notes below about configuring postgreSQL for UTF-8 and setting up the user needed

- phantomJS this is the 'headless browser' used for some of the Cucumber tests
  - see [the poltergeist gem page for instructions on installing phantomJS](https://github.com/teampoltergeist/poltergeist).
  (The poltergeist gem uses phantomJS.)




## Installation

Most of the installation is about getting postgreSQL set up.  If you already have it set up and working, then you just need to check to see if it will handle UTF-8 (Unicode), and then set up the right user.


1. Get the `.env` file.

   Sensitive or secret information (e.g. Google map API key) in maintained in this file in the project home directory
    ```
   .env
   ```

   That file will not be present in the environment when you first clone it because it is not maintained in git - and thus is not pulled down from github. Contact one of the project members to get the contents of that file (for example via private message in Slack, or general message in the project's Slack channel).

2. Make sure you have **postgres** installed and running and configured to handle UTF-8.

   2.1  You need to make sure it is installed on your system.  You can run `psql -V` to see if it's installed. [Note the **capital** 'V'] If it is installed, it should tell you the psql version.
   2.2  You need to make sure it is running on your system.  The way to check this varies with your OS. (See below)  
   2.3  You need to make sure it is configured to handle UTF-8
 
 
   - 2.1 & 2.2: Here are some standard ways to get postgress installed and configured:
   
     - mac OS:
     
       - install
       - start
       - stop
         
     - windows 7 and above
   
     - cloud 9
   
       - We have to use UTF8 encoding.  This WILL AFFECT your workspace! 
       - you may need to create a new workspace 
     
       - start postgres:  
         ` sudo service postgresql start`

         
   2.3 PostgreSQL must be configurated to handle **unicode**  (utf-8)
       
   The database must work with UTF-8 characters, so it must be created and set up to handle it.
   Some postgres installations (like on Cloud9) don't have this configured correctly by default, so you must be sure that can handle UTF-8.
       
   - How to check: (TBD)
       
   - How to configure it for UTF-8:
       
       - will adding the line `template: template0'in the `default:` section of `database.yml` do it?
       
   
         
3. Create the postgres database **user** for the project.  (a.k.a. "role")

   You must create the `shf_project' user in postgres.  This is the 'owner' of the databases.
   
   *TODO:  Is this right?  Is it necessary for the development and test databases?*

   3.1 Cloud9:
   - You need to log in as the `postgres super user`
    `sudo su - postrgres;`
   -  Your prompt should start with this: _postgres@_
   -  (as the postgres user) create the 'shf_project' user: `createuser shf_project -dslP`
    'shf_project' is the *owner* of the databases used
      - you will be asked for a password for your user. Just hit return without entering a password.
    
   - Now create the database for your application: `create database <your project db name> owner=<your project db name user>`

   

  
You should now have postgreSQL installed, running, configured to handle UTF-8 (Unicode) and the 'shf_project' user (role) created.
   
   

4. Run the `shf:db_recreate` rake task to automatically set up the specific postgreSQL databases and seed with fake data
   
   This will not only create the db, but will also ensure that the data needed is _loaded in the correct order_ and then will seed with some fake data that you can use.
   
   This task runs these standard `db:` rake tasks:
  
    - db:create, db:drop, db:create, db:migrate
    
    It then loads data that is required for the system _in the correct order_ (because some data depends on other already existing in the db):
    
    - shf:load_regions, shf:load_kommuns
    
    And then finally it will seed the database with some fake data by running 
    
    - db:seed
    
    (You can look at the source in `lib/tasks/shf.rake`)


5.  Yay!

_(TODO: more information on installation process?)_



## Running and Using the SHF Project

Run the rails server in the application directory ( `rails s` )  When you go to the home page, you should see a list of companies and map of the companies.

You can switch languages by clicking on the little round flag icon in the upper right-hand corner. (Clicking on the British flag will switch to English. Clicking on the Swedish flag will switch to Swedish.)

You can 'apply for membership' by:
1.  Registering as a user
2.  Filling out and submitting a membership application


You can log in as an administrator by using the email and password in the `.env` file.  Then you can manage incoming membership applications (you can approve or reject memberships, or ask them for more information, etc.).
As an administrator, you can also edit anyone's company or membership information.

As a member, you can edit the page for your company.  You can add custom information and format it using the CKEditor we have in place.


## Tell us!

If you have any questions, please ask!

If you run into any errors, please, PLEASE let us know on Slack!

If you have any suggestions, please _do_ let us know!

The best way to give us your feedback is on our [AgileVentures Slack channel: #shf-project](http://agileventures.slack.com).   

If you're not an AgileVentures member, you can create an issue here in GitHub.  We use [our PivotalTracker instance](https://www.pivotaltracker.com/n/projects/1904891) to track issues.  We use GitHub to document things and as our public repo.


## Contributing:

Interested? Our contribution guidelines describes how to contribute, including information about our git workflow and our standards for using GitHub issues and pull requests (PRs).

_(TODO: create and then link the contribution guidelines here)_

_(TODO: do you need to be a member of AgileVentures to contribute?  a paid member? A line here about AV would be helpful since not all will take the time to go read more in our contribution guildelines.)_

## Problems?

If have any problems, please  **[search through the issues](https://github.com/AgileVentures/shf-project/issues) first** to see if it's already been addressed. If you do not find an existing issue, then open a new issue.
Please describe the problem in detail including information about your operating system (platforms), version, etc.  The more detail you can provide, the more likely we can address it.



##License

The authors and contributors have agreed to license all other software
under the MIT license, an open source free software license. See the
file named COPYING which includes a disclaimer of warranty.
