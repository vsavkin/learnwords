# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_learnwords_session',
  :secret      => '14c320611c6eca7d72097cd08ab5da2c3578e9729e63546ad49f4d61855f3fd98f1c3f86f7ac0ce7044dc75aa5f3d05d6131f6b52e0f7873045f3b8e67ff585f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
