import { Controller } from "@hotwired/stimulus"
import L from 'leaflet'

// Connects to data-controller="map"
export default class extends Controller {
  static targets = ["placeholder", "latitude", "longitude"]

  connect() {
    import("leaflet").then(L => {
        this.map = L.map(this.placeholderTarget).setView([this.latitudeTarget.textContent, this.longitudeTarget.textContent], 18);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 20,
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(this.map);
        L.marker([this.latitudeTarget.textContent, this.longitudeTarget.textContent]).addTo(this.map);
    });
  }

  disconnect() {
      this.map.remove()
  }
}
