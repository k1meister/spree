import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content", "reviewForm"]

  connect() {
    // Show reviews tab by default
    this.switchTab({ currentTarget: this.tabTargets.find(t => t.dataset.tab === "reviews") })
  }

  switchTab(event) {
    const clickedTab = event.currentTarget
    const tabName = clickedTab.dataset.tab

    // Update tab buttons
    this.tabTargets.forEach(tab => {
      if (tab === clickedTab) {
        tab.classList.add("active", "font-semibold", "text-gray-900", "border-b-2", "border-gray-900")
        tab.classList.remove("font-medium", "text-gray-600")
      } else {
        tab.classList.remove("active", "font-semibold", "text-gray-900", "border-b-2", "border-gray-900")
        tab.classList.add("font-medium", "text-gray-600")
      }
    })

    // Update content
    this.contentTargets.forEach(content => {
      if (content.dataset.tab === tabName) {
        content.classList.remove("hidden")
      } else {
        content.classList.add("hidden")
      }
    })
  }

  showReviewForm(event) {
    event.preventDefault()
    
    // Switch to reviews tab
    const reviewsTab = this.tabTargets.find(t => t.dataset.tab === "reviews")
    if (reviewsTab) {
      this.switchTab({ currentTarget: reviewsTab })
    }

    // Show review form
    if (this.hasReviewFormTarget) {
      this.reviewFormTarget.classList.remove("hidden")
      
      // Scroll to form
      this.reviewFormTarget.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }
}

