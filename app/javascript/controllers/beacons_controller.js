import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "beaconApiKey"]

  copyApiKey() {
    const apiKey = this.beaconApiKeyTarget.textContent;
    
    navigator.clipboard.writeText(apiKey).then(() => {
      const button = this.buttonTarget;
      const originalText = button.textContent;
      button.textContent = "Copied!";
      button.classList.add("text-green-600");
      
      setTimeout(() => {
        button.textContent = originalText;
        button.classList.remove("text-green-600");
      }, 2000);
    }).catch(err => {
      console.error("Failed to copy:", err);
      alert("Failed to copy API key to clipboard");
    });
  }
}
