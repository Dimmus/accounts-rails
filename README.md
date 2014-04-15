accounts-rails
=============

A rails engine for interfacing with OpenStax's accounts server.

Usage
-----

Add the engine to your Gemfile and then run `bundle install`.  

Mount the engine your application's `routes.rb` file:

    MyApplication::Application.routes.draw do
      ...
      mount OpenStax::Accounts::Engine, at: "/accounts"
      ...
     end

You can use whatever path you want instead of `/accounts`, just make sure to make the appropriate changes below.

Create an `openstax_accounts.rb` initializer in `config/initializers`, with the following contents:

    OpenStax::Accounts.configure do |config|
      config.openstax_application_id = 'value_from_openstax_accounts_here'
      config.openstax_application_secret = 'value_from_openstax_accounts_here'
    end

If you're running OpenStax Accounts in a dev instance on your machine, you can specify that instance's local URL with:

    config.openstax_accounts_url = 'http://localhost:2999/'

To have users login, direct them to `/accounts/sessions/new`.  This is also available through the `openstax_accounts.login` route helper, e.g. `<%= link_to 'Sign in!', openstax_accounts.login_path %>`.

There is also a logout path helper for `/accounts/sessions/destroy`, given by `logout_path`.  By default this expects a `GET` request.  If you'd prefer a `DELETE` request, add this configuration:

    config.logout_via = :delete

OpenStax Accounts provides you with an `OpenStax::Accounts::User` object.  You can
use this as your app's User object without modification, you can modify it to suit
your app's needs (not recommended), or you can provide your own custom User object
that references the OpenStax Accounts User object.  

OpenStax Accounts also provides you methods for getting and setting the current 
signed in user (`current_user` and `current_user=` methods).  If you choose to create 
your own custom User object that references the User object provided by Accounts, 
you can teach OpenStax Accounts how to translate between your app's custom User 
object and OpenStax Accounts's built-in User object.

To do this, you need to set a `user_provider` in this configuration.  

    config.user_provider = MyUserProvider

The user_provider is a class that provides two class methods:

    def self.accounts_user_to_app_user(accounts_user)
      # Converts the given accounts user to an app user.
      # If you want to cache the accounts_user in the app user,
      # this is the place to do it.
      # If no app user exists for this accounts user, one should
      # be created.
    end
  
    def self.app_user_to_accounts_user(app_user)
      # Converts the given app user to an accounts user.
    end 

Accounts users are never nil.  When a user is signed out, the current accounts user 
is an anonymous user (responding true to `is_anonymous?`).  You can follow the same
pattern in your app or you can use nil for the current user.  Just remember to check
the anonymous status of accounts users when doing your accounts <-> app translations.

The default `user_provider` just uses OpenStax::Accounts::User as the app user.

Make sure to install the engine's migrations:

    rake openstax_accounts:install:migrations

Accounts API
------------

OpenStax::Accounts provides convenience methods for accessing the OpenStax Accounts API.

`OpenStax:: Accounts.create_application_user(accounts_user, version = nil)` takes
an OpenStax::Accounts::User and, optionally, an API version argument, and creates
an ApplicationUser for the configured application and the given user. Call this method
when users finish the registration process in your app. This lets Accounts know that the given user is using your app, allowing Accounts to push user information to it whenever it changes.

`OpenStax::Accounts.api_call(http_method, url, options = {})` provides a generic
convenience method capable of making API calls to Accounts. `http_method` can be
any valid HTTP method, and `url` is the desired API URL, without the 'api/' prefix.
Options is a hash that can contain any option that OAuth2 requests accept, such
as :headers, :params, :body, etc, plus the optional values :api_version (to specify
an API version) and :access_token (to specify an OAuth access token).

Example Application
-------------------

There is an example application included in the gem in the `example` folder.
Here are the steps to follow:

1. Download (clone) the OpenStax Accounts site from github.com/openstax/accounts.  
1. In the site's `config` folder put a `secret_settings.yml` file that has values for the 
following keys: `facebook_app_id`, `facebook_app_secret`, `twitter_consumer_key`, `twitter_consumer_secret`.  If you don't have access to these values, you can always make dummy apps on facebook and twitter.
2. Do the normal steps to get this site online:
    1. Run `bundle install --without production`
    2. Run `bundle exec rake db:migrate`
    3. Run `bundle exec rails server`
2. Open this accounts site in a web browser (defaults to http://localhost:2999)
3. Navigate to http://localhost:2999/oauth/applications
4. Click `New application`
    5. Set the callback URL to `http://localhost:4000/accounts/auth/openstax/callback`.  
Port 4000 is where you'll be running the example application.
    1. The name can be whatever.
    2. Click the `Trusted?` checkbox.
    3. Click `Submit`.
    4. Keep this window open so you can copy the application ID and secret into the example app
5. Leave the accounts app running
6. Download (clone) the OpenStax Accounts gem from github.com/openstax/accounts-rails. 
The example application is in the `example` folder.
In that folder's config folder, create a `secret_settings.yml` file according to the
instructions in `secret_settings.yml.example`. Run the example server in the normal way (bundle install..., migrate db, rails server).
7. Navigate to the home page, http://localhost:4000.  Click log in and play around.  You can also refresh the accounts site and see yourself logged in, log out, etc.
8. For fun, change example/config/openstax_accounts.rb to set `enable_stubbing` to `true`.  Now when you click login you'll be taken to a developer-only page where you can login as other users, generate new users, create new users, etc.