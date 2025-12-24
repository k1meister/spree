import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'
import debounce from 'spree/core/helpers/debounce'

export default class extends Controller {
  static targets = ['input']
  static values = {
    url: String
  }

  connect() {
    this.debouncedQuerySuggestions = debounce(this.querySuggestions.bind(this), 300)
    this.inputTarget.addEventListener('input', this.debouncedQuerySuggestions)
    
    // Check if this is header search (has dropdown) or modal search
    this.dropdown = this.element.querySelector('#search-suggestions-dropdown')
    this.isHeaderSearch = !!this.dropdown
    
    if (this.isHeaderSearch) {
      // Header search: use inline dropdown
      this.content = this.dropdown.querySelector('#search-suggestions-content')
      this.inputTarget.addEventListener('blur', this.hideSuggestions)
      this.inputTarget.addEventListener('focus', this.showSuggestionsIfHasValue)
    } else {
      // Modal search: use existing modal system
      this.openSearchButton = document.querySelector('#open-search')
      if (this.openSearchButton) {
        this.openSearchButton.addEventListener('click', this.show)
      }
      
      this.searchSuggestionsContainer = document.querySelector('#search-suggestions')
      if (this.searchSuggestionsContainer) {
        this.searchSuggestionsContent = this.searchSuggestionsContainer.querySelector('#search-suggestions-content')
        this.loadingHTML = this.searchSuggestionsContainer.querySelector('template#loading')?.innerHTML
        Turbo.StreamActions[`search-suggestions:close`] = this.remoteClose(this)
      }
    }
  }

  remoteClose = (controller) => {
    return function () {
      controller.hide()
    }
  }
  
  disconnect() {
    this.inputTarget.removeEventListener('input', this.debouncedQuerySuggestions)
    
    if (this.isHeaderSearch) {
      this.inputTarget.removeEventListener('blur', this.hideSuggestions)
      this.inputTarget.removeEventListener('focus', this.showSuggestionsIfHasValue)
    } else {
      delete Turbo.StreamActions[`search-suggestions:close`]
      if (this.openSearchButton) {
        this.openSearchButton.removeEventListener('click', this.show)
      }
    }
  }
  
  hideSuggestions = () => {
    // Delay to allow click on suggestion
    setTimeout(() => {
      if (this.dropdown) {
        this.dropdown.classList.add('hidden')
      }
    }, 200)
  }
  
  showSuggestionsIfHasValue = () => {
    if (this.inputTarget.value.length >= 2) {
      this.querySuggestions()
    }
  }
  
  hide = () => {
    if (this.searchSuggestionsContainer) {
      this.searchSuggestionsContainer.style.display = 'none'
    }
  }
  
  clear = () => {
    if (this.searchSuggestionsContent) {
      this.searchSuggestionsContent.innerHTML = ''
      this.searchSuggestionsContent.classList.remove(...this.searchSuggestionsContent.dataset.showClass.split(' '))
      this.searchSuggestionsContent.classList.add('hidden')
      this.element.classList.remove(...this.element.dataset.showClass.split(' '))
    }
  }
  
  show = () => {
    if (this.searchSuggestionsContainer) {
      this.searchSuggestionsContainer.style.display = 'block'
      this.inputTarget.focus()
      const oldInputValue = this.inputTarget.value
      this.inputTarget.value = ''
      this.inputTarget.value = oldInputValue
    }
  }
  
  querySuggestions = async () => {
    const query = this.inputTarget.value.trim()
    const minLength = this.isHeaderSearch ? 2 : 3
    
    if (query.length >= minLength) {
      if (this.isHeaderSearch) {
        // Header search: show inline dropdown
        if (this.dropdown) {
          this.dropdown.classList.remove('hidden')
        }
        if (this.content) {
          this.content.innerHTML = '<div class="text-center py-4 text-gray-500 text-sm">Yükleniyor...</div>'
        }
      } else {
        // Modal search: use existing system
        if (this.searchSuggestionsContent && this.loadingHTML) {
          this.searchSuggestionsContent.innerHTML = this.loadingHTML
          this.searchSuggestionsContent.classList.remove('hidden')
          this.searchSuggestionsContent.classList.add(...this.searchSuggestionsContent.dataset.showClass.split(' '))
          this.element.classList.add(...this.element.dataset.showClass.split(' '))
        }
      }
      
      try {
        const url = this.isHeaderSearch 
          ? `${this.urlValue}?q=${encodeURIComponent(query)}&header=true`
          : `${this.urlValue}?q=${encodeURIComponent(query)}`
        
        await get(url, {
          responseKind: 'turbo-stream'
        })
      } catch (error) {
        console.error('Search suggestions error:', error)
        if (this.isHeaderSearch && this.content) {
          this.content.innerHTML = '<div class="text-center py-4 text-gray-500 text-sm">Bir hata oluştu</div>'
        }
      }
    } else {
      if (this.isHeaderSearch && this.dropdown) {
        this.dropdown.classList.add('hidden')
      }
    }
  }
}
