import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    // Set first tab as active by default
    if (this.tabTargets.length > 0) {
      this.showTab(this.tabTargets[0].dataset.tabId)
    }
  }

  switchTab(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    this.showTab(tabId)
  }

  showTab(tabId) {
    // Hide all content
    this.contentTargets.forEach(content => {
      content.classList.add("hidden")
    })

    // Remove active state from all tabs
    this.tabTargets.forEach(tab => {
      tab.classList.remove("border-orange-500", "text-orange-600", "font-semibold")
      tab.classList.add("border-transparent", "text-gray-600", "font-medium")
    })

    // Show selected content
    const selectedContent = this.contentTargets.find(content => content.dataset.tabContent === tabId)
    if (selectedContent) {
      selectedContent.classList.remove("hidden")
    }

    // Add active state to selected tab
    const selectedTab = this.tabTargets.find(tab => tab.dataset.tabId === tabId)
    if (selectedTab) {
      selectedTab.classList.remove("border-transparent", "text-gray-600", "font-medium")
      selectedTab.classList.add("border-orange-500", "text-orange-600", "font-semibold")
    }
  }
}


