# restart server if this file is changed

Rails.application.config.session_store :active_record_store, key: '_opdash_session'
# also available: httponly, which is true/false
