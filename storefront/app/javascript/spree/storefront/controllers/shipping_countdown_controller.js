import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['hours', 'minutes', 'seconds', 'message', 'separator1', 'separator2']
  static values = {
    cutoffTime: String, // ISO string of cutoff time
    shippingDate: String, // 'today' or 'tomorrow'
    reloadUrl: String
  }

  connect() {
    this.updateCountdown()
    this.interval = setInterval(() => {
      this.updateCountdown()
    }, 1000)
  }

  disconnect() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  updateCountdown() {
    const now = new Date()
    const cutoff = new Date(this.cutoffTimeValue)
    const diff = cutoff - now

    if (diff <= 0) {
      // Time expired, reload page to get next day
      if (this.reloadUrlValue) {
        window.location.href = this.reloadUrlValue
      } else {
        window.location.reload()
      }
      return
    }

    // Calculate days, hours, minutes, seconds
    const totalSeconds = Math.floor(diff / 1000)
    const days = Math.floor(totalSeconds / (24 * 60 * 60))
    const hours = Math.floor((totalSeconds % (24 * 60 * 60)) / (60 * 60))
    const minutes = Math.floor((totalSeconds % (60 * 60)) / 60)
    const seconds = totalSeconds % 60

    // Update display - show days if > 0
    if (this.hasHoursTarget) {
      if (days > 0) {
        // Show days and hours: "1 gün 17"
        this.hoursTarget.textContent = `${days} gün ${String(hours).padStart(2, '0')}`
        // Show separators when showing days (for hours:minutes:seconds)
        if (this.hasSeparator1Target) {
          this.separator1Target.style.display = 'inline'
        }
        if (this.hasSeparator2Target) {
          this.separator2Target.style.display = 'inline'
        }
      } else {
        // Show only hours: "17"
        this.hoursTarget.textContent = String(hours).padStart(2, '0')
        // Show separators when not showing days
        if (this.hasSeparator1Target) {
          this.separator1Target.style.display = 'inline'
        }
        if (this.hasSeparator2Target) {
          this.separator2Target.style.display = 'inline'
        }
      }
    }
    if (this.hasMinutesTarget) {
      this.minutesTarget.textContent = String(minutes).padStart(2, '0')
    }
    if (this.hasSecondsTarget) {
      this.secondsTarget.textContent = String(seconds).padStart(2, '0')
    }
  }
}

