# https://github.com/rails/activerecord-session_store
# By default, creates a table "sessions" with the keys
# 'id', numeric, primary
# 'session_id', string (varchar), maxlen 255,
# 'data', text or similar, assume a maxlen of 65535 bytes
# usually also (and in our case):
# 'created_at', datetime
# 'updated_at', datetime
# As for the 'data' column, whatever is stored in there has been serialized
# by the core Marshal class (http://ruby-doc.org/core-2.4.1/Marshal.html)
# (assuming the default hasn't been changed)
# and then idk what happens afterwards or how it's used

class Session < ActiveRecord::SessionStore::Session

end
