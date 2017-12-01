Contributing to SFH-project
===========================

We welcome your help and contributions.  This project is an [AgileVentures](http://AgileVentures.org) project.
It is a collaborative, open project that uses Agile methods. This GitHub repo is one part of the project.


#### Here are the main tools we use to work together and handle our work-flow:

- We use **[our Project pages](http://www.agileventures.org/projects/shf-project)** to document the main information about the project


- We use **[PivotalTracker](https://www.pivotaltracker.com/n/projects/1904891)** to discuss, define, and track our work (tasks, issues, bugs, features, ....).  We don't use GitHub for this.

- We use **[our channel on Slack](https://agileventures.slack.com/messages/shf-project/)** to have ongoing discussions and share information.  

- We use **GitHub** as the main repository for our code (version control, branches) and merge in work (PRs).

_Details on all of this are below. Read on for more on how it all goes._

**If you find a bug, but aren't going to join the project,** then [feel free to create an issue here on GitHub](https://github.com/AgileVentures/shf-project/issues) . We'd love to have your feedback.

---

## Join the Project:

1) You'll need (free) accounts for these tools:

- [GitHub](http://github.com)
- [Pivotal Tracker](http://www.pivotaltracker.com)
- [Slack](http://slack.com)


2) Once you have accounts for those, create a profile on AgileVentures:
     Go to [AgileVentures.com](http://www.agileventures.org/) and sign up (look in the upper right-hand corner).
     You can sign up with *your GitHub account.*  That way, your work on GitHub will automatically be connected to the project and our tools.

3) You should automatically get an email from info@agileventures.com that invites you to our Slack team.

 If you don't get the invite for some reason, just send email to info@agileventures.com. (It would be helpful if you included your GitHub account name just to be complete.)

4) Get connected to our Pivotal Tracker project:

- Go to the Slack channel for this project: #shf-project and say hello!
- Then ask to be connected to our Pivotal Tracker project. Tell us the email address you use with your Pivotal Tracker account.


Now start asking questions and talking on Slack, reading about what needs to be done on PivotalTracker, reviewing past meetings via the videos that were recorded, do some Pair Programming, and be a part of the project!


[**Getting Started on the AgileVentures site**](http://www.agileventures.org/getting-started) provides more details about being involved in projects and more about [AgileVentures.](http://www.agileventures.org)

---

## Code Style
We recommend the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).  

---  

## Workflow: Working on Code, coordinating with GitHub

Here is an overview of the general process for contributing (working on a new feature or fixing a bug):

- Once you have chosen something to work on _and_ discussed it in a team scrum meeting:   

    -> checkout 'develop' branch  (fast forward so you're up to date)
    -> create a branch for your work in your repo
    -> write test(s) to pass
    -> get your tests passing
    -> create a WIP PR
    -> discuss, revise as needed
    -> remove 'WIP' when your PR is ready to be reviewed
    -> PR is reviewed and approved by at least 2 SHF developers
    -> PR is merged by a project manager
    -> Yay!



### Detailed Guidelines:
  - [Defining Tasks with PivotalTracker](#Defining-Tasks-with-PivotalTracker)
    - [Features](#Features)
    - [Bug fixes](#Bug-fixes)
  - [GitHub Workflow](#GitHub-Workflow)
    - develop = The branch for doing work
    - Fork the repo if you haven't already
    - Create a new branch for your work
    - Create a *WIP* PR early so others can review and help
      -  One change per PR
    - Pull Request Review
    - Remove [WIP] and merge




---


## Defining Tasks with PivotalTracker

We use [Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1904891) to manage our work on features, chores and bugfixes.

Work is defined in Pivotal Tracker.  Discussions take place there, in Slack, and in live conversations in scrums and pair programming (currently we mostly use Google Hangouts).

### Features
Any feature should include Cucumber acceptance tests and RSpec tests where appropriate.

 Generally we do not use unit-level tests for views. Views should be thoroughly tested and exercised with feature (cucumber) tests.
 But we do unit tests for situations that require those - for instance:
   1. confirming that menu views are rendered consistent with our menu structure design, and
   2. confirming the presence of hidden elements, HTML attributes, etc. that
    could not be easily tested (if at all) in a cucumber test.



### Bug fixes

Fixing a bug should **start with the creation of a test that replicates the bug,** so that any bugfix submission will include an appropriate test as well as the fix itself.

A bugfix may include an acceptance test depending on where the bug occurred.



_TODO_  _where should this user story go in the code?  as a cucumber acceptance test or as a documentation block?  in the github issue?_

Where possible please include a user story or stories in the following form to indicate the higher level issue that is being addressed:

```gherkin
As an administrator
So that I can try new project metrics
I would like to be able to be able to add metrics with the minimum amount of effort

As an investigator
So that I can see how projects performed historically on new metrics
I would like to be able to apply new metrics to historical data on projects

As a metric designer
So that I can share my new metric
I would like to be able to package my metric into a gem as simply as possible

As a project supervisor
So that I can quickly review project progress
I would like a view of metrics for a project that loads within 7 seconds, and ideally even faster

As an administrator of another site that has projects
So that I can quickly and reliably get stats on all our projects
I would like to be able to access the project metrics via API

```


## GitHub Workflow

### develop = The branch for doing work

Our default working branch is currently `develop`.  We do work by creating branches off `develop` for new features and bugfixes.  

### Fork the repo if you haven't already  
Each developer will usually work with a [fork](https://help.github.com/articles/fork-a-repo/) of the [main repository on Agile Ventures](https://github.com/AgileVentures/shf-project).

#### ...or sync your fork before starting on a new story
Before starting work on a new feature or bugfix, please ensure you have [synced your fork to upstream/develop](https://help.github.com/articles/syncing-a-fork/):

```
git pull upstream develop
```

Note that you should be re-syncing daily (even hourly at very active times) on your feature/bugfix branch to ensure that you are always building on top of very latest _develop_ code.


### Create a new branch for your work

When you create a branch to work on your feature or bug-fix, please name your branch so that others can understand the context, purpose, and intent for it.

Our naming convention has two requirements:
  1. Include a short description of the PT story, and,
  2. Include, somewhere, the PT story number.

For example, this template works for branch name:  `[sprintNN or target_release]-[Pivotal Tracker ID number]-[short-story-description] `

This example also complies: `company-branding-fee#152725653`.


For example, lets say you are working on a feature in _sprint 24,_  the ID for that story in PivotalTracker is _1059872,_ and the title of that story is _"Add the CONTRIBUTING.md file",_ you can create and check out your branch like this:

```
git checkout -b sprint24-#1059872-add-contributing-md
```
or, perhaps like this:
```
git checkout -b add-contributing-md#1059872
```

Note that it's ok to include the `#` in the branch name.  You can leave it in there or not; it's optional.

Once you have your tests passing (or if you're stuck and need help), you're ready to submit a pull request.



#### Sync again before you create a PR

Before you make a pull request it is a great idea to sync again to the upstream develop branch to reduce the chance that there will be any merge conflicts arising from other PRs that have been merged to _develop_ since you started work:

```
git pull upstream develop
```


### Create a *WIP* PR early so others can review and help

Be sure to create your PR against the **develop** branch!

We connect the PR in GitHub to the PivotalTracker story manually (simple, but quick and explicit):
- put a link to the PivotalTracker story in the PR description, _and_
- update the name of the story in PivotalTracker story so that it starts with the PR number. (You have to save the PR first to get the number.)
    Ex:  If the PR number that GitHub assigns is _357_ and the original story name in Pivotal Tracker is _"Add the CONTRIBUTING.md file,"_ then edit the story name to be _"357 - Add the CONTRIBUTING.md file"_

   **This makes it quick and easy for someone scanning the stories in PivotalTracker to see if there's a PR for a story.**




Whatever you are working on, **please open a "Work in Progress" (WIP)** [pull request](https://help.github.com/articles/creating-a-pull-request/) (just start your PR title with "[WIP]" ) so that others in the team can comment on your approach.  Even if you hate your horrible code. :-) Please throw it up there and we'll help guide your code to fit in with the rest of the project.

Team members can review and give you feedback as you work. This helps ensure that you don't go too far down a path that isn't going to work out.

[This flow chart shows how our PR process works with our main branches.](./docs/dev-workflow/github-flow.png).



#### One change per PR

Please ensure that each commit in your pull request makes a _single_ coherent change and that the overall pull request only includes commits related to the specific Pivotal Tracker story (feature, chore, bug) that the pull request is addressing.
This helps the project managers understand the PRs and merge them more quickly.

If your PR is addressing a GitHub issue (which doesn't happen much in this project), please include a sensible description of your code and a tag `fixes #<issue-id>` e.g. :

```
This PR adds a CONTRIBUTING.md file and a docs directory

fixes #799
```

which will mean that the issue is automatically linked to the pull request in the GitHub interface and when the pull request gets merged the issue will be closed.



### Pull Request Review

The project manager(s) will review the pull request for coherence with the specified feature or bug fix, and give feedback on code quality, user experience, documentation and git style.  Please respond to comments from the project managers with explanation, or further commits to your pull request in order to get merged in as quickly as possible.

To maximize flexibility, any contributor should be able to push changes to your branch to update your PR, and you should allow edits from maintainers. Doing both things lets them help your improve your PR efficiently.  

### Remove [WIP] and merge
Once your WIP PR is working and you believe it's ready to be merged into the project, edit the PR title and remove "[WIP]".  Removing "[WIP]" is a signal that your PR is ready for a final review.  (Others will know that you have finished working on it; that it's no longer in flux.)  Make any changes as needed from the review(s).  Once the reviewers are happy and your code is passing all integration checks, your PR will be merged into the `develop` branch and be closed!   
