# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chart.js" # @4.4.7
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
pin "chart.js/auto", to: "chart.js--auto.js" # @4.4.7
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "channels", to: "channels.js"
pin_all_from "app/javascript/channels", under: "channels"
