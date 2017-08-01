# restart server if this file is changed

#Rails.application.config.session_store :active_record_store, key: '_opdash_session'
# apparently since Rails 5 (or sth) this stuff no longer belongs here but in
# config/application.rb
# also available: httponly, which is true/false
