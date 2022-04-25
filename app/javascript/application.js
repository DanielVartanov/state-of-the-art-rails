// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"


// This event listener is added to ensure a proper importing of Bootstrap javascript
// See `#my-alert` in app/views/messages/index.haml.haml
document.addEventListener("turbo:load", function(event) {
    var myAlert = document.getElementById('my-alert')
    var alert = new bootstrap.Alert(myAlert)
    alert.close()
});
