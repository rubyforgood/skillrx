import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    this.setupNavbarScroll();
    this.setupSmoothScroll();
    this.setupIntersectionObserver();
    this.setupLoadingStates();
    this.setupIconErrorHandling();
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleNavbarScroll);
  }

  // Navbar scroll effect
  setupNavbarScroll() {
    this.handleNavbarScroll = () => {
      const navbar = document.querySelector(".navbar");
      if (navbar && window.scrollY > 50) {
        navbar.classList.add("scrolled");
      } else if (navbar) {
        navbar.classList.remove("scrolled");
      }
    };
    window.addEventListener("scroll", this.handleNavbarScroll);
  }

  // Smooth scroll for anchor links
  setupSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
      anchor.addEventListener("click", (e) => {
        e.preventDefault();
        const targetId = anchor.getAttribute("href");
        const target = document.querySelector(targetId);
        if (target) {
          const navbarHeight =
            document.querySelector(".navbar")?.offsetHeight || 76;
          const targetPosition = target.offsetTop - navbarHeight;
          window.scrollTo({
            top: targetPosition,
            behavior: "smooth",
          });
        }
      });
    });
  }

  // Add loading animation for cards with intersection observer
  setupIntersectionObserver() {
    const observerOptions = {
      threshold: 0.1,
      rootMargin: "0px 0px -50px 0px",
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
          setTimeout(() => {
            entry.target.style.opacity = "1";
            entry.target.style.transform = "translateY(0)";
          }, index * 100);
          observer.unobserve(entry.target);
        }
      });
    }, observerOptions);

    // Observe cards
    const cards = document.querySelectorAll(".card");
    cards.forEach((card) => {
      card.style.opacity = "0";
      card.style.transform = "translateY(20px)";
      card.style.transition = "all 0.6s ease";
      observer.observe(card);
    });

    // Handle statistics animation
    const statistics = document.querySelectorAll(".statistic h3");
    statistics.forEach((stat) => {
      observer.observe(stat.parentElement);
    });
  }

  // Handle button loading states
  setupLoadingStates() {
    document
      .querySelectorAll('a[href*="session"], button[type="submit"]')
      .forEach((button) => {
        button.addEventListener("click", function () {
          if (!this.classList.contains("loading")) {
            this.classList.add("loading");
            const originalText = this.innerHTML;
            this.innerHTML =
              '<i class="bi bi-hourglass-split me-2"></i>Loading...';

            // Reset after 3 seconds if still loading
            setTimeout(() => {
              if (this.classList.contains("loading")) {
                this.classList.remove("loading");
                this.innerHTML = originalText;
              }
            }, 3000);
          }
        });
      });
  }

  // Add error handling for missing icons
  setupIconErrorHandling() {
    const icons = document.querySelectorAll('i[class*="bi-"]');
    icons.forEach((icon) => {
      const computedStyle = window.getComputedStyle(icon, "::before");
      if (!computedStyle.content || computedStyle.content === "none") {
        console.warn("Icon not loading:", icon.className);
      }
    });
  }
}
