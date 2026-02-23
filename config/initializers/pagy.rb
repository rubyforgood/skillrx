# frozen_string_literal: true

# Pagy initializer file (43.2.4)
# See https://ddnexus.github.io/pagy/resources/initializer/


# Pagy Variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#variables
# You can set any pagy variable as a Pagy::DEFAULT. They can also be overridden per instance by just passing them to
# Pagy.new|Pagy::Countless.new|Pagy::Calendar::*.new or any of the #pagy* controller methods
# Here are the few that make more sense as DEFAULTs:
# Pagy::DEFAULT[:limit]       = 20                    # display 20 results per page to match UI expectations
# Pagy::DEFAULT[:size]        = 7                     # default
# Pagy::DEFAULT[:ends]        = true                  # default
# Pagy::DEFAULT[:page_param]  = :page                 # default
# Pagy::DEFAULT[:count_args]  = []                    # example for non AR ORMs
# Pagy::DEFAULT[:max_pages]   = 3000                  # example


# Extras
# See https://ddnexus.github.io/pagy/categories/extra


# Legacy Compatibility Extras

# Size extra: Enable the Array type for the `:size` variable (e.g. `size: [1,4,4,1]`)
# See https://ddnexus.github.io/pagy/docs/extras/size
# require 'pagy/extras/size'   # must be required before the other extras


# Backend Extras

# Arel extra: For better performance utilizing grouped ActiveRecord collections:
# See: https://ddnexus.github.io/pagy/docs/extras/arel
# require 'pagy/extras/arel'

# Array extra: Paginate arrays efficiently, avoiding expensive array-wrapping and without overriding
# See https://ddnexus.github.io/pagy/docs/extras/array
# require 'pagy/extras/array'

# Calendar extra: Add pagination filtering by calendar time unit (year, quarter, month, week, day)
# See https://ddnexus.github.io/pagy/docs/extras/calendar
# require 'pagy/extras/calendar'
# Default for each calendar unit class in IRB:
# >> Pagy::Calendar::Year::DEFAULT
# >> Pagy::Calendar::Quarter::DEFAULT
# >> Pagy::Calendar::Month::DEFAULT
# >> Pagy::Calendar::Week::DEFAULT
# >> Pagy::Calendar::Day::DEFAULT
#
# Pagy.options[:limit] = 10               # Limit the items per page
# Pagy.options[:client_max_limit] = 100   # The client can request a limit up to 100
# Pagy.options[:max_pages] = 200          # Allow only 200 pages
# Pagy.options[:jsonapi] = true           # Use JSON:API compliant URLs


# Frontend Extras

# Bootstrap extra: Add nav, nav_js and combo_nav_js helpers and templates for Bootstrap pagination
# See https://ddnexus.github.io/pagy/docs/extras/bootstrap
# require "pagy/extras/bootstrap"

# Bulma extra: Add nav, nav_js and combo_nav_js helpers and templates for Bulma pagination
# See https://ddnexus.github.io/pagy/docs/extras/bulma
# require 'pagy/extras/bulma'

# Pagy extra: Add the pagy styled versions of the javascript-powered navs
# and a few other components to the Pagy::Frontend module.
# See https://ddnexus.github.io/pagy/docs/extras/pagy
# require 'pagy/extras/pagy'

# Multi size var used by the *_nav_js helpers
# See https://ddnexus.github.io/pagy/docs/extras/pagy#steps
# Pagy::DEFAULT[:steps] = { 0 => 5, 540 => 7, 720 => 9 }   # example


# Feature Extras

# Gearbox extra: Automatically change the limit per page depending on the page number
# See https://ddnexus.github.io/pagy/docs/extras/gearbox
# require 'pagy/extras/gearbox'
# set to false only if you want to make :gearbox_extra an opt-in variable
# Pagy::DEFAULT[:gearbox_extra] = false               # default true
# Pagy::DEFAULT[:gearbox_limit] = [15, 30, 60, 100]   # default

# Limit extra: Allow the client to request a custom limit per page with an optional selector UI
# See https://ddnexus.github.io/pagy/docs/extras/limit
# require 'pagy/extras/limit'
# set to false only if you want to make :limit_extra an opt-in variable
# Pagy::DEFAULT[:limit_extra] = false    # default true
# Pagy::DEFAULT[:limit_param] = :limit   # default
# Pagy::DEFAULT[:limit_max]   = 100      # default

# Overflow extra: Allow for easy handling of overflowing pages
# See https://ddnexus.github.io/pagy/docs/extras/overflow
# require 'pagy/extras/overflow'
# Pagy::DEFAULT[:overflow] = :empty_page    # default  (other options: :last_page and :exception)

# Trim extra: Remove the page=1 param from links
# See https://ddnexus.github.io/pagy/docs/extras/trim
# require 'pagy/extras/trim'
# set to false only if you want to make :trim_extra an opt-in variable
# Pagy::DEFAULT[:trim_extra] = false # default true

# Standalone extra: Use pagy in non Rack environment/gem
# See https://ddnexus.github.io/pagy/docs/extras/standalone
# require 'pagy/extras/standalone'
# Pagy::DEFAULT[:url] = 'http://www.example.com/subdir'  # optional default

# Jsonapi extra: Implements JSON:API specifications
# See https://ddnexus.github.io/pagy/docs/extras/jsonapi
# require 'pagy/extras/jsonapi'   # must be required after the other extras
# set to false only if you want to make :jsonapi an opt-in variable
# Pagy::DEFAULT[:jsonapi] = false  # default true

# Rails
# Enable the .js file required by the helpers that use javascript
# (pagy*_nav_js, pagy*_combo_nav_js, and pagy_limit_selector_js)
# See https://ddnexus.github.io/pagy/docs/api/javascript

# With the asset pipeline
# Sprockets need to look into the pagy javascripts dir, so add it to the assets paths
# Rails.application.config.assets.paths << Pagy.root.join('javascripts')

# I18n

# Pagy internal I18n: ~18x faster using ~10x less memory than the i18n gem
# See https://ddnexus.github.io/pagy/docs/api/i18n
# Notice: No need to configure anything in this section if your app uses only "en"
# or if you use the i18n extra below
#
# For apps with a javascript builder (e.g. esbuild, webpack, etc.)
# javascript_dir = Rails.root.join('app/javascript')
# Pagy.sync_javascript(javascript_dir, 'pagy.mjs') if Rails.env.development?


############# Overriding Pagy::I18n Lookup #################################################
# Refer to https://ddnexus.github.io/pagy/resources/i18n/ for details.
# Override the I18n lookup by dropping your custom dictionary in some pagy dir.
# Example for Rails:
#
# Pagy::I18n.pathnames << Rails.root.join('config/locales/pagy')


############# I18n Gem Translation #########################################################
# See https://ddnexus.github.io/pagy/resources/i18n/ for details.
#
Pagy.translate_with_the_slower_i18n_gem!


############# Calendar Localization for non-en locales ####################################
# See https://ddnexus.github.io/pagy/toolbox/paginators/calendar#localization for details.
# Add your desired locales to the list and uncomment the following line to enable them,
# regardless of whether you use the I18n gem for translations or not, whether with
# Rails or not.
#
# Pagy::Calendar.localize_with_rails_i18n_gem(*your_locales)

# When you are done setting your own default freeze it, so it will not get changed accidentally
Pagy.options.freeze
