import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]

  connect() {
    this.updateActiveLink()
  }

  filterProducts(event) {
    event.preventDefault()
    const clickedLink = event.currentTarget

    // Update active state
    this.linkTargets.forEach(link => {
      link.dataset.active = (link === clickedLink).toString()
      link.classList.toggle('text-indigo-600', link === clickedLink)
      link.classList.toggle('text-gray-700', link !== clickedLink)
    })

    // Fetch filtered products
    fetch(clickedLink.href, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Turbo-Frame': 'products-grid'
      }
    }).then(response => {
      Turbo.visit(clickedLink.href, { action: 'replace' })
    })
  }

  updateActiveLink() {
    const currentCategory = new URLSearchParams(window.location.search).get('category')
    
    this.linkTargets.forEach(link => {
      const linkCategory = new URLSearchParams(new URL(link.href).search).get('category')
      const isActive = (!currentCategory && !linkCategory) || (currentCategory === linkCategory)
      
      link.dataset.active = isActive.toString()
      link.classList.toggle('text-indigo-600', isActive)
      link.classList.toggle('text-gray-700', !isActive)
    })
  }
}
