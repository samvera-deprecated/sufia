# Sufia [![Version](https://badge.fury.io/rb/sufia.png)](http://badge.fury.io/rb/sufia) [![Build Status](https://travis-ci.org/projecthydra/sufia.png?branch=master)](https://travis-ci.org/projecthydra/sufia) [![Dependency Status](https://gemnasium.com/projecthydra/sufia.png)](https://gemnasium.com/projecthydra/sufia)

## What is Sufia?
Sufia is a component that adds self-deposit institutional repository features to a Rails app. 
Sufia is created with Ruby on Rails and builds on the Hydra Framework.

Sufia has the following features:

* Multiple file, or folder, upload
* Flexible user- and group-based access controls
* Transcoding of audio and video files 
* Generation and validation of identifiers
* Fixity checking
* Version control
* Characterization of uploaded files
* Forms for batch editing metadata
* Faceted search and browse (based on Blacklight)
* Social media interaction
* User profiles
* User dashboard for file management
* Highlighted files on profile
* Sharing w/ groups and users
* User notifications
* Activity streams
* Background jobs
* Single-use links

## Sufia needs the following software to work:
1. Solr
1. [Fedora Commons](http://www.fedora-commons.org/) digital repository
1. A SQL RDBMS (MySQL, SQLite)
1. [Redis](http://redis.io/) key-value store
1. [ImageMagick](http://www.imagemagick.org/)
1. Ruby

#### !! Ensure that you have all of the above components installed before you continue. !!

## Creating an application
### Generate base Rails install
```rails new my_app```
### Add gems to Gemfile
```
gem 'sufia'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'  # required to handle pagination properly in dashboard. See https://github.com/amatsuda/kaminari/pull/322
```
Then `bundle install`

Note the line with kaminari listed as a dependency.  This is a temporary fix to address a problem in the current release of kaminari.  Technically you should not have to list kaminari, which is a dependency of blacklight and sufia. 

### Run the sufia generator
```
rails g sufia -f
```

### Run the migrations

```
rake db:migrate
```

### Get a copy of hydra-jetty
```
rake jetty:clean
rake jetty:config
rake jetty:start
```

### If you want to use the CSS and JavaScript and other assets that ship with Sufia...
#### Modify app/assets/stylesheets/application.css
Add this line:
```
 *= require sufia
```
**Remove** this line:  
```*= require_tree .```  

_Removing the require_tree from application.css will ensure you're not loading the blacklight.css.  This is because blacklight's css styling does not mix well with sufia's default styling._ 


#### Modify app/assets/javascripts/application.js

Add this line:
```
//= require sufia
```

**Remove** this line, if present (typically, when using Rails 4):
```
//= require turbolinks
```

Turbolinks does not mix well with Blacklight.

### If you want to use browse-everything
Sufia provides built-in support for the [browse-everything](https://github.com/projecthydra/browse-everything) gem, which provides a consolidated file picker experience for selecting files from [DropBox](http://www.dropbox.com), 
[Skydrive](https://skydrive.live.com/), [Google Drive](http://drive.google.com), 
[Box](http://www.box.com), and a server-side directory share.

To activate browse-everything in your sufia app, run the browse-everything config generator

```
rails g browse_everything:config
```

This will generate a file at _config/browse_everything_providers.yml_.  Open that file and enter the API keys for the providers that you want to support in your app.  For more info on configuring browse-everything, go to the [project page](https://github.com/projecthydra/browse-everything) on github.

After running the browse-everything config generator and setting the API keys for the desired providers, an extra tab will appear in your app's Upload page allowing users to pick files from those providers and submit them into your app's repository.

*Note*: If you want to use the built-in browse-everything support, _you need to include the browse-everything css and javascript files_.  If you already included the sufia css and javascript (see [above](#if-you-want-to-use-the-css-and-javascript-and-other-assets-that-ship-with-sufia)), then you don't need to do anything.  Otherwise, follow the instructions in the [browse-everything README page](https://github.com/projecthydra/browse-everything)

*If your config/initializers/sufia.rb was generated with sufia 3.7.2 or older*, then you need to add this line to an initializer (probably _config/initializers/sufia.rb _):
```ruby
config.browse_everything = BrowseEverything.config
```

### Install Fits.sh
1. Go to http://code.google.com/p/fits/downloads/list and download a copy of fits & unpack it somewhere on your machine.  You can also install fits on OSX with homebrew `brew install fits` (you may also have to create a symlink from `fits.sh -> fits` in the next step).
1. Give your system access to fits
    1. By adding the path to fits.sh to your excutable PATH. (ex. in your .bashrc)
        * OR
    1. By adding/changing config/initializers/sufia.rb to point to your fits location:   `config.fits_path = "/<your full path>/fits.sh"`
1. You may additionally need to chmod the fits.sh (chmod a+x fits.sh)
1. You may need to restart your shell to pick up the changes to you path
1. You should be able to run "fits.sh" from the command line and see a help message

### Start background workers
**Note:** Resque relies on the [redis](http://redis.io/) key-value store.  You must install [redis](http://redis.io/) on your system and *have redis running* in order for this command to work.
To start redis, you usually want to call the `redis-server` command.

```
QUEUE=* rake environment resque:work
```

For production you may want to set up a config/resque-pool.yml and run resque pool in daemon mode

```
resque-pool --daemon --environment development start
```

See https://github.com/defunkt/resque for more options

### If you want to enable transcoding of video, install ffmpeg version 1.0+
#### On a mac
Use homebrew:
```
brew install ffmpeg --with-fdk-aac --with-libvpx --with-libvorbis
```

#### On Ubuntu Linux
See https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide

## Developers:
This information is for people who want to modify the engine itself, not an application that uses the engine:

# run the tests
rake clean spec
```

### Change validation behavior

To change what happens to files that fail validation add an after_validation hook
```
    after_validation :dump_infected_files

    def dump_infected_files
      if Array(errors.get(:content)).any? { |msg| msg =~ /A virus was found/ }
        content.content = errors.get(:content)
        save
      end
    end
```


## Editing the about page.

If you edit your `app/models/ability.rb` file you can give edit access to some users.  If you add:
```ruby
  can :update, Page
```

Then every user will be able to edit the about page via the web editor.
