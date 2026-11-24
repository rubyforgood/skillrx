# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-use" # @0.52.3
pin "tom-select" # Local vendor file with ES module wrapper

# Ruby For Good design system components, vendored as standalone files (Lit bundled in) from
# @rubyforgood/design-system@0.1.3. Provenance and how to upgrade are in each file's header.
pin "rfg-avatar", to: "rfg-avatar.js"
pin "rfg-button", to: "rfg-button.js"
pin "rfg-menu", to: "rfg-menu.js"
pin "rfg-callout", to: "rfg-callout.js"
pin "rfg-field", to: "rfg-field.js"
