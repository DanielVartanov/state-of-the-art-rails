// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import * as bootstrap from "bootstrap"

document.addEventListener("turbo:load", function(event) {
    var myAlert = document.getElementById('my-alert')
    var alert = new bootstrap.Alert(myAlert)
    alert.close()
});

Rails.start()
ActiveStorage.start()
