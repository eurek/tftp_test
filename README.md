# README

## Intro

Time for the Planet® is a website to help raise money and find entrepreneurs to create companies dedicated to fight climate change.

Purchasing shares is done using a [Typeform](https://www.typeform.com/), whose link is found on [this page](https://www.time-planet.com/devenir-associee).

Projets content is controlled by editors via a CMS.

Check the website : https://www.time-planet.com

## Technical stack

Time for the Planet® is developped using Ruby on Rails. 

For JavaScript, it uses the framework [Stimulus](https://stimulusjs.org/).

Editor can publish new contents using [Active Admin](https://activeadmin.info/) with the theme [Arctic Admin](https://github.com/cprodhomme/arctic_admin).

A continuous integration system is set up using [Circle CI](https://circleci.com/) to launch tests from Github. The website is deployed through [Heroku](https://heroku.com). Errors are catched with [Sentry](https://sentry.io).

[Sidekiq](https://github.com/mperham/sidekiq) is used for background processing. 

## Style

### Grid

This website uses only the grid system of [Bootstrap](https://getbootstrap.com/)

### BEM

For CSS, we use the BEM (Block Element Modifier) methodology. The principle is to organize CSS code by component (the Block), then by Elements of the components, and then create variants (the Modifiers) if needed. We use SCSS, so the different classes should be nested.

Example :

```
# app/assets/stylesheets/components/_card.scss

.Card {
  display: flex;
  padding: 1 rem;
  border-radius: 3px;
  
  &--dark {
    background-color: $black;
    color: $white;
  }
  
  &--light {
    background-color: $white;
    color: $black;
  }
  
  &-title {
    font-weight: bold;
    font-size: 1.5;
  }
  
  &-content {
    font-size: 1rem
    
    &--dark {
      color: $grey-50;
    }
  
    &--light {
      color: $dark-grey;
    }
  }
}
```

## Install project

### Clone the repository

``` 
git clone git@github.com:EmmanuelleN/time-planet.git
cd mon-time-planet
```
### Check you Ruby version

```
ruby -v
``` 

The ouput should start with something like ruby 2.6.5

If not, install the right ruby version using rbenv (it could take a while):

```
rbenv install 2.6.5
```

### Install dependencies

Using Bundler and Yarn:

```
bundle && yarn
```
### Environment variables

Most of the sensitive data you need like api keys and such are in the credentials contained in an encrypted file.

To get the master key, needed to use the credentials contact the developer at emmanuelle@nada.computer (sensitive data).

You can still set environment variables if you need using the [dotenv](https://github.com/bkeepers/dotenv) gem.

### Initialize the database

```
rails db:create db:migrate db:seed
``` 

### Add Heroku remote

Using the command line:

``` 
heroku git:remote -a time-planet
```

## Serve

Start rails server :
```
rails s
``` 

Start sidekiq to enable background processing
```
sidekiq
```


## Deploy Staging and Production

There is an Heroku pipeline in place with an integration with Github. So when there is a new commit merged in master
branch it is automatically pushed on [staging app](https://staging-time-planet.herokuapp.com).
Staging is protected by basic auth to avoid duplicated content penalties with google.
Username: `user`, password: `password`

To deploy from staging to production once the features has been tested on staging, there is a button 
`Promote to production` on heroku pipeline webapp.

When we make a new release to production we need to publish the changes list in the slack channel #releases to inform
keepers about the changes.
You can consult the last commit that has been pushed to production on production app within heroku's pipeline. 
With a git log in your terminal you can then know which new commits will be promoted to production.

> Be careful when deploying, always add new environment variables to Heroku before deploying.

## Work with real data

There are tasks to replicate data from production db and S3 bucket in local to be able to work with real data.
To use them you'll need to have awscli installed.

Install awscli
```
brew install awscli
```

Launch task
```
rails replicate:prod_to_dev
```


## Code Style

This project uses [rubocop](https://github.com/rubocop-hq/rubocop) with a configuration taken from 
[standard](https://github.com/testdouble/standard/blob/master/config/base.yml)

To check your code style :
```
bundle exec rubocop
```

## Content

A default call to action is defined for contents using variable `default_cta_id` contained in credentials. You can define
an environment variable `DEFAULT_CTA_ID` to override it.

## Content Translations

### Content saved in database
All contents that are saved in database (Content, Category, Tag, Badge, Role, ...) are translated using `:jsonb` 
backend of [mobility gem](https://github.com/shioyama/mobility). As the backend's name suggests, model's attributes
that needs to be translated are stored in jsonb column with one key-value pair for each locale. For example if we have
a title attribute on a model translated in multiple languages, the hash that will be saved in db for this column will
look like this:
```json
{ 
    "en": "Content's title",
    "fr": "Titre du contenu",
    "it": "Titolo del contenuto"
} 
```
Mobility gem handles all the work to let us set and get attributes as usual :
```ruby
I18n.locale = :fr
content = Content.new
content.title = "Le titre de mon article"
content.save
content.title #=> "Le titre de mon article"

I18n.locale = :en
content.title #=> "Le titre de mon article" (fallback to :fr locale)
content.title(fallback: false) #=> nil
content.title = "Content's title"
content.save
content.title #=> "Content's title"
```

See [mobility documentation](https://github.com/shioyama/mobility) for more detailed information on how the gem works

### Static content
For static contents we use Rails built-in I18n but we added a different backend using 
[I18n-active-record gem](https://github.com/svenfuchs/i18n-active_record). This gem allows us to save translation keys
in db. This allows admin users to have access to them and to translate them in Active Admin back-office.
Translations are saved in `translations` table. Each translation has a locale and a key attributes that allow us
to target it when we want to use it and a value that is going to be displayed.

When we use `I18n.translate` it will first look for the key in db and if it can't find it, it will fallback
for the key present in yml files.

As developers when we need to create a new translation key, we create it in yml files first, then we have a rake task
to save them in database when it has been pushed to production. This rake task needs to be called with arguments so
the syntax is a little different. For example is the yml files looks like this: 
```yml
---
fr:
  home:
    title: "We are the last generation that can save the planet."
    subtitle: "The way we use our money, defines the world we want to live in."
```

The rake task to save the home title and subtitle in db should be called like this:
```bash
rails translations:load_yml_files
```
This rake will go through all yml files and add all translation keys. It won't create a new translation in db if there
is already one with the same key in db. It will delete keys from db that are no longer present in yml files.

### How to add a new locale in the project
1. Add new locale in available locales in `config/application.rb`
2. Create a yml file for the new locale in `config/locales/routes/`
   This yml file should contain all translations of translated urls. For now these translations should be found in
   [this spreadsheet](https://docs.google.com/spreadsheets/d/1W45abT5e4Mn6Qh6QZewaerL7fCAIdIHgYlFnCC5SUxI/edit?pli=1#gid=630252710)
3. Copy the meta image translated in the requested locale in the directory `app/assets/images/meta_images`
4. Once the new locale is in production, it is preferable to translate quickly following translation key:
   - `common.flag` that is used to display a flag for the locale 
     (used in `app/views/shared/_language_switcher.html.erb`).
     You can find circular flag codes on [icons8](https://icons8.com/icon/set/flags/color)
   - `common.language` that is used to display the language's name in the locale (Français for fr, or English for en).
     It might be better to check with the translator that the translation is ok especially if we're not able to
     understand that language

You can check [this PR](https://github.com/TimeForPlanet/time-planet/pull/638) 
as an example of what to do to add a locale.

For now we usually add the locale in the system first. Wait for the translators to add all necessary translations in
the back office. When we consider the locale ready to make it public, we can add it in the language switcher 
`app/views/shared/_language_switcher.html.erb`

## Git Flow

### Branches

When you want to add some code, you create a new branch from the branch `master` or any other branch with : 
```
git checkout -b $name-of-the-new-branch
```

The branch name should start with a prefix suggesting what kind of PR it will be :
- `feat` for a new feature or part of a new feature
- `fix` for a bug fix
- `design` when there will only be some front integration (a new page would probably be prefixed with feat)
- `chore` when it will only add configuration, upgrade gems, add some documentation ...
So for example a branch name should look like : `feat/add-home-page`

You should regularly commit (`git commit -m "name of your commit"`) and push your code to github even if you don't open a PR to be sure that even if your computer crash,
you will not loose your code.

### Pull Request

When you think you're done with what you wanted to achieve, you can push your code (`git push`) and open a PR on Github. 
Someone will review your code, probably make some comments and ask for modifications. 

Ideally a PR should be small enough to make it easily reviewable. More than 600 line changes starts to get big.

When you need to do some modifications, you checkout your branch (`git chechout $name-of-your-branch`), 
make the requested changes, make a new commit and push your new code. 
As you commited your changes in a new commit or multiple commits you don't need to do a `git push -f` 
or `git push --force`!! and the reviewer will easily be able to see the changes you added by consulting
only the commits you added.

If at some point in the review process, github is telling you that your branch is out of date with the base branch
or that your branch has conflict with the base branch :
- You checkout your branch `git chechout $name-of-your-branch`
- You fetch all data that git needs from remote repository with `git fetch`
- Then you merge master into your branch with `git merger origin/master`
- At this point, if you have conflict, git will stop the merge process to allow you to resolve the conflicts. 
Git will indicate the files where there are conflicts, so you can go in the code to resolve them.
- When this is done you can tell git to continue with `git merge --continue`
- Then push your branch to the remote repository with a simple `git push`


The reviewer will not be able to review your code as soon as you push it. So if you need the code of a PR you already
opened to continue your work (for example you added a new model and now you will do a second PR to add a controller
and views) you can checkout the branch of the first PR and then create a new branch from this one with the same command
than above so for example:
```
git checkout feat/added-new-modal
git checkout -b feat/add-controller-and-views
```
Then follow the same process than explained above.

If at some point you do some requested modifications on your first PR and you need them in your second one you can do
merge your first branch in the second one with the same process than before so with our example:
```
git checkout feat/add-controller-and-views
git merge feat/added-new-modal
```
if you don't have conflict then you're done but if you do resolve them and then
```
git merge --continue
```
 
When your PR is approved by the reviewer, we do a `Squash and Merge` in Github. When you click on 
Squash and merge, Github will open a window to make you choose the name of the commit and the description. 
So if needed you can change the name of the commit before confirming and you should copy the url of the PR and paste it
in the description input. Then you can confirm.


## Performances

### PgHero

[PgHero](https://github.com/ankane/pghero/blob/master/guides/Rails.md) is setup to capture statistics about 
database queries. It can allow us to get information about slowest queries for example.

It can also tell which indexes are not used or suggest other indexes to add to improve performances.

To access data you have to be logged in as admin user and then visit `/pghero`

Data stored by PgHero can get big so it's a good idea to clear the table from time to time with
```
PgHero.clean_query_stats
```

