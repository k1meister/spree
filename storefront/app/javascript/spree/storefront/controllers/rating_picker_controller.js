import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['star', 'input']

  connect() {
    this.updateDisplay()
  }

  update() {
    this.updateDisplay()
  }

  updateDisplay() {
    const selectedRating = this.inputTargets.find(input => input.checked)?.value || 0
    
    this.starTargets.forEach((star, index) => {
      if (index < selectedRating) {
        star.classList.remove('text-gray-300')
        star.classList.add('text-orange-500')
      } else {
        star.classList.remove('text-orange-500')
        star.classList.add('text-gray-300')
      }
    })
  }
}

