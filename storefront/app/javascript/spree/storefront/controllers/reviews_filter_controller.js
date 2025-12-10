import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "ratingSort", "sortFilter", "reviewsContainer"]

  connect() {
    this.filter()
  }

  filter() {
    const searchTerm = this.searchTarget?.value?.toLowerCase() || ''
    const ratingSort = this.ratingSortTarget?.value || 'all'
    const sortFilter = this.sortFilterTarget?.value || 'recent'
    
    const reviews = this.reviewsContainerTarget?.querySelectorAll('.review-card-advanced') || []
    
    reviews.forEach(review => {
      const rating = parseInt(review.dataset.rating) || 0
      const reviewText = (review.dataset.reviewText || '').toLowerCase()
      
      const matchesSearch = !searchTerm || reviewText.includes(searchTerm)
      
      if (matchesSearch) {
        review.classList.remove('hidden')
      } else {
        review.classList.add('hidden')
      }
    })
    
    // Sort reviews
    const visibleReviews = Array.from(reviews).filter(r => !r.classList.contains('hidden'))
    let sortedReviews = this.sortReviews(visibleReviews, sortFilter)
    
    // Apply rating sort (best/worst)
    if (ratingSort === 'best') {
      sortedReviews = sortedReviews.sort((a, b) => {
        const ratingA = parseInt(a.dataset.rating) || 0
        const ratingB = parseInt(b.dataset.rating) || 0
        return ratingB - ratingA
      })
    } else if (ratingSort === 'worst') {
      sortedReviews = sortedReviews.sort((a, b) => {
        const ratingA = parseInt(a.dataset.rating) || 0
        const ratingB = parseInt(b.dataset.rating) || 0
        return ratingA - ratingB
      })
    }
    
    // Reorder in DOM
    sortedReviews.forEach(review => {
      this.reviewsContainerTarget.appendChild(review)
    })
    
    // Update review count
    const countElement = document.querySelector('[data-reviews-filter-target="reviewCount"]')
    if (countElement) {
      const visibleCount = sortedReviews.length
      countElement.textContent = `1-${Math.min(visibleCount, 5)}`
    }
  }

  sortReviews(reviews, sortBy) {
    const sorted = [...reviews]
    
    switch(sortBy) {
      case 'recent':
        sorted.sort((a, b) => {
          const dateA = new Date(a.querySelector('time')?.getAttribute('datetime') || 0)
          const dateB = new Date(b.querySelector('time')?.getAttribute('datetime') || 0)
          return dateB - dateA
        })
        break
      case 'helpful':
        // Sort by helpful count (for now, just keep order)
        break
      case 'relevant':
        // Sort by rating first, then recent
        sorted.sort((a, b) => {
          const ratingA = parseInt(a.dataset.rating || 0)
          const ratingB = parseInt(b.dataset.rating || 0)
          if (ratingB !== ratingA) return ratingB - ratingA
          const dateA = new Date(a.querySelector('time')?.getAttribute('datetime') || 0)
          const dateB = new Date(b.querySelector('time')?.getAttribute('datetime') || 0)
          return dateB - dateA
        })
        break
    }
    
    return sorted
  }

  helpful(event) {
    event.preventDefault()
    const button = event.currentTarget
    const count = button.querySelector('span')
    const currentCount = parseInt(count.textContent) || 0
    count.textContent = currentCount + 1
    button.classList.add('text-orange-500')
  }

  notHelpful(event) {
    event.preventDefault()
    const button = event.currentTarget
    const count = button.querySelector('span')
    const currentCount = parseInt(count.textContent) || 0
    count.textContent = currentCount + 1
    button.classList.add('text-red-500')
  }
}


