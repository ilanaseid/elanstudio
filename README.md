# elanstudio

Repo for elanstudio.com.

Production: http://www.elanstudio.com/

Staging: http://staging.elanstudio.com/

Preview: http://preview.elanstudio.com/

Local Development: http://0.0.0.0:5000/

## TOC

1. [Development Environment Setup](#development-environment-setup)
2. [Development Tasks and Tests](#development-tasks-and-tests)
3. [Additional Documentation](#additional-documentation)
4. [Additional Resources](#additional-resources)

## Development Environment Setup

Here are the installation and managment instructions for runing the application on OS X

### Combined Instructions For All Tools + App
_updated 6/2/2015_

The following instructions assume a fresh OS X Yosemite install, if you have previously installed any of the tools listed below, be aware that you may have to upgrade rather than install tools, or at least swap paths or other configuration options from the default configuration options used below:

These instructions will get you a running copy of our application in the folder ~/Sites/elanstudio, with data, and tools for backend and front end development.

Some steps Adapted from installation guides for [RVM on Yosemite](http://foffer.dk/install-ruby-on-os-x-10-10-yosemite-using-rvm/) and [Rails on Yosemite](http://railsapps.github.io/installrubyonrails-mac.html)


1. Install Apple Xcode (App Store)
2. Open Xcode and let components automatically install
3. Open a Terminal window
  type `xcode-select -p` and you should see /Applications/Xcode.app/contents/Developer
  type: `xcode-select —-install` and you should be prompted to install the command line toosl

4. Download and install Java JDK (to support solr QUESTION: is this the best way to install and maintain?)
  type `java -version` and press “more info...” in the resulting dialog

5. Install [Homebrew](http://brew.sh)
  type: `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

  (note: you may have to reload your terminal instance to get your paths updated at this point)

6. Install a minty fresh version of git
  type `brew install git`

7. Install other needed apps via brew
	* type `brew install redis`
	* type `brew install postgresql`
	* type `brew install homebrew/versions/mongodb26`
	* type `brew install node`
	* type `brew install heroku`
  * type `brew install imagemagick`

8. Configure mongodb data directory
  type `sudo mkdir -p /data/db`
  type `sudo chown *[username]* /data/db` (where [username] is output of `whoami`)

9. Configure env vars
  edit ~/.bash_profile
  add the line `export PGDATA=/usr/local/var/postgres`

10. Install RVM
  type: `curl -sSL https://get.rvm.io | bash -s stable`

  (note: you may have to reload your terminal instance to get your paths updated at this point)

11. Install the latest Ruby
  type `rvm install ruby`

  (note: if the app is using a different ruby than latest you may have to explicitly ionstall that version)

12. Grab updates of your global gems
  type `gem update`

14. install bundler
  type `gem install bundler`

15. Move into or create the folder you want to store your project files
  type: `mkdir ~/Sites; cd ~/Sites`

16. Configure and Authenticate GitHub Account. See [Help Docs](https://help.github.com/articles/set-up-git/)

17. Clone elanstudio and clear_cms engine repos onto your local machine (type or use Github GUI to clone)
  type: `git clone git@github.com:ilanaseid/elanstudio.git`
  type `git clone git@github.com:captain-lucas/clear_cms.git`

18. Move into the folder for elanstudio
  type `cd elanstudio`

19. Build all Ruby dependencies
  type `bundle`

20. Install Grunt CLI tools and build all front end dev tools dependencies
  type `npm install -g grunt-cli`
  type `npm install`

21. In separate new Terminal windows, temporarily start services
  in one type `postgres`
  in another type `mongod`
  in another type `redis-server`

22. In the original terminal window, build db data
  type `rake db:setup`

23. Shut down each of the three 3 services you started (control-C)

  NOTE: at this point I had some processes still running and couldn’t start with foreman - need proper workflow for temporarily starting and then cleanly shutting down.

24. Log into Heroku (note: needs Heroku account access/temporary production access)
  type `heroku login`

25. Grab a copy of our data
  type `script/backup_and_pull_production`

26. Attempt to start your local server
  type `foreman start -f Procfile.dev`

27. With server running, in a new tab update the db to match the latest build from master, not production where you grabbed the data
  type `rake db:migrate`

28. Also, with server running, in that tab rebuild solr indexes
  type `rake sunspot:reindex`


#### Additional / Optional Dev Tools
_updated 11/14/2014_
_TODO: document specific sublime packages_

* Install [Dropbox](https://www.dropbox.com/downloading) and upgrade to a "PRO" license
* Install [Sublime Text 3](http://www.sublimetext.com/3) purchase a license, and install package control [ https://sublime.wbond.net/installation ]
* Install the [GitHub Mac Client](https://mac.github.com)
* Set sublime alias in .bash_profile `alias subl='open -a "Sublime Text 2"'` to use subl to open files in terminal
* Show elanstudio rake tasks with `rake -T elanstudio`



### Upgrade Rails versions (OS X)

When we've moved the project to a new ruby version you will have to update your dev machine to match:

1. Type `rvm get head` to get latest rubies information
2. Type `rvm install ruby-2.1.3` (or whatever version you're attempting to install)
3. You may have to open a new terminal window for it to be aware of the new versions/environment
4. Type `bundle` to rebuild all your dependencies (may take some time)

### OLD -- App Installation (elanstudio.com) -- OLD
_TODO: reclassify this section - is it needed? put it with testing?_

This is DESTRUCTIVE, use for dev only to seed Spree products and link them to CMS content (this wipes all SQL data but only CMS content data for Mongo)
`PRODUCT_COUNT=100 EDITORIAL_COUNT=20 rake elanstudio:dummy_data:load`

* To recreate image versions (you'll need to have your .env exported so it can access the S3 bucket). It recreates the versions from the originals stored on S3, and right now the image count is hard coded based on how many images there are for product or editorial:
`rake elanstudio:recreate_test_images:all`
or
`rake elanstudio:recreate_test_images:product`
`rake elanstudio:recreate_test_images:editorial`





## Development Tasks and Tests

## Running the Test Suite
* Must have [Firefox](https://www.mozilla.org/en-US/firefox/new/) installed
* `foreman start -f Procfile.dev` (to manage DB servers)
* New tab: `rspec`


### Running Frontend Development Grunt Tasks
* Change to the project's root directory.
* Install project dependencies with npm install.
* Run all default Grunt with `grunt`.
* Recreate icon set from /src/assets/images/icons with `grunt svg`

### App Deployment (elanstudio.com)
To list current remote repositories
`git remote`
If first time deploying, need to run:
`heroku keys:add ~/.ssh/id_rsa.pub`

Add remote for staging
`git remote add staging git@heroku.com:elanstudio-staging.git`
Force a push to staging
`git push -f staging`
Force a push of a branch to staging
`git push -f staging HEAD:master` (if on the branch locally)
`git push -f staging branchname:master`

For demo or preview we use

Add remote for preview
`git remote add preview git@heroku.com:elanstudio-preview.git`
Force a push to preview
`git push -f preview`
Force a push of a branch to preview
`git push -f preview HEAD:master` (if on the branch locally)
`git push -f preview branchname:master`




## Additional Documentation


* TODO: List of Google Doc Names/Dropbox locations


## Additional Resources

### Browser and Platform Targets

#### Desktop Platforms - Alpha Dogs
* Firefox Latest Mac OS
* Chrome Latest Mac OS
* Safari Latest Mac OS
* Firefox Latest Windows
* Chrome Latest Windows
* IE 9+ Windows (with Touch)

#### Mobile Platforms - Alpha Dogs
* iPhone 5 Safari (latest)
* iPad Retina Safari (latest)
* Current Windows Phone
* Current Android Phone
* Current Andriod Tablet

#### Maybe Keep an Eye on
* IE 8 Windows
* Non-Retina iPhone & iPad
* iOS Chrome (latest)
* Google Nexus Tablets (latest)
* Amazon Kindle Fire HDX Tablets (latest)

### Browser & Device Testing
* http://browserstack.com [Chris has account]
* Adobe Edge Inspect [Anyone with Adobe CC can install]


### Gateway Testing Card #'s
* TEST_VISA = 4111 1111 1111 1111
* TEST_MC = 5555 5555 5555 4444
* TEST_AMEX = 3782 822463 10005
* TEST_DISC = 6011 1111 1111 1117
* Additional Info: https://www.braintreepayments.com/docs/ruby/reference/sandbox
* NOTE: Cart Totals in the $2000-$3100 range should fail

### Status Pages for Services

* [Airbrake](http://status.airbrake.io/)
* [Amazon Web Services](http://status.aws.amazon.com/) (S3)
* [Asana](http://www.asanastatus.com/) & [Asama Ops Twitter](https://twitter.com/AsanaOps)
* [Braintree Payments](https://status.braintreepayments.com/)
* [Brightpearl](http://status.brightpearl.com/)
* [Chartbeat](http://status.chartbeat.com/)
* [DNSimple](http://dnsimplestatus.com/)
* [Dropbox](https://twitter.com/DropboxOps)
* [GitHub](https://status.github.com/)
* [Google App Status Dashboard](http://www.google.com/appsstatus#hl=en&v=status) (Gmail, Analytics, etc.)
* [Heap Analytics](http://status.heapanalytics.com/)
* [Heroku](https://status.heroku.com/)
* [Librato](http://status.librato.com/)
* [Logentries](https://status.logentries.com/)
* [MailChimp](http://status.mailchimp.com/)
* [MongoLab](http://status.mongolab.com/)
* [NewRelic](https://status.newrelic.com/)
* [Optimizely](http://status.optimizely.com/)
* [Pivotal Tracker ](http://status.pivotaltracker.com/)
* [RubyGems.org](http://status.rubygems.org/)
* [Redis Cloud](https://status.redislabs.com/)
* [Semaphore](https://twitter.com/semaphoreci)
* [SendGrid](http://labs.sendgrid.com/status/)
* [ShipStation](https://twitter.com/ShipStation)
* [WebSolr](http://help.websolr.com/kb/status-reports)






