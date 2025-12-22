// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Add any globally defined hooks here
let Hooks = {};

Hooks.Slideshow = {
  mounted() {
    const track = this.el.querySelector('.slides-track');
    const slides = this.el.querySelectorAll('.slide');
    let currentSlide = 0;
    const totalSlides = slides.length;

    const goToSlide = (index, animate = true) => {
      if (animate) {
        track.style.transition = 'transform 1.5s cubic-bezier(0.77, 0, 0.175, 1)';
      } else {
        track.style.transition = 'none';
      }
      track.style.transform = `translateX(-${index * (100 / totalSlides)}%)`;
    };

    const nextSlide = () => {
      currentSlide += 1;
      goToSlide(currentSlide, true);

      // If we've reached the duplicate slide, reset instantly to the first
      if (currentSlide === totalSlides - 1) {
        setTimeout(() => {
          goToSlide(0, false);
          currentSlide = 0;
        }, 1500); // match the transition duration
      }
    };

    // Initial position
    goToSlide(currentSlide);

    // Change slide every 5 seconds
    this.interval = setInterval(nextSlide, 5000);
  },

  destroyed() {
    if (this.interval) {
      clearInterval(this.interval);
    }
  }
};

// Add this part to merge page-specific hooks
// It looks for a `ViewHooks` object on the window and merges it into the main Hooks object.
let ViewHooks = window.ViewHooks || {};
Object.assign(Hooks, ViewHooks);

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks // This now includes your page-specific hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#10B981"}, shadowColor: "rgba(0, 0, 0, .25)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
// The line below is important for this approach!
window.liveSocket = liveSocket

