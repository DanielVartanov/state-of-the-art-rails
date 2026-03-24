import { Controller } from "@hotwired/stimulus"
import { Alert } from "bootstrap"

// Automatically dismisses a Bootstrap alert when connected to the DOM.
// Usage: <div class="alert" data-controller="auto-dismiss">...</div>
export default class extends Controller {
  connect() {
    const alert = new Alert(this.element)
    alert.close()
  }
}
