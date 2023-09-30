# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "bootstrap", to: "bootstrap.min.js"
pin "@popperjs/core", to: "popper.js"

pin_all_from "app/javascript/components", under: "components"