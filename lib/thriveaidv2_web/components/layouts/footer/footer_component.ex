defmodule Thriveaidv2Web.Components.Layouts.Footer.FooterComponent do
  use Thriveaidv2Web, :html

  def footer(assigns) do
    current_year = Date.utc_today().year

    ~H"""
    <footer class="bg-black text-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-16">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8 md:gap-12">
          <!-- Logo and Mission -->
          <div class="col-span-1 md:col-span-2">
            <div class="flex items-center mb-4">
              <img src={~p"/images/logo.jpg"} alt="ThriveAid Logo" class="h-10 w-auto"/>
              <span class="ml-3 text-xl font-bold text-green-400">ThriveAid</span>
            </div>
            <p class="text-gray-400 mb-6">
              Empowering communities and transforming lives through sustainable development and compassionate action. We aid young people in actualizing their potential and capitalizing on their abilities to achieve success.
            </p>
            <div class="flex space-x-4">
              <a href="https://www.facebook.com/profile.php?id=100077229891510&mibextid=ibOpuV" target="_blank" rel="noopener noreferrer" class="text-gray-400 hover:text-green-400 transition-colors">
                <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
              </a>
              <a href="https://www.linkedin.com/in/thrive-aid-40a4682b2/" target="_blank" rel="noopener noreferrer" class="text-gray-400 hover:text-green-400 transition-colors">
                <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
              </a>
            </div>
          </div>

          <!-- Quick Links -->
          <div>
            <h3 class="text-lg font-semibold text-green-400 mb-4">Quick Links</h3>
            <ul class="space-y-2">
              <li><a href={~p"/about"} class="text-gray-400 hover:text-white transition-colors">About Us</a></li>
              <li><a href={~p"/what-we-do"} class="text-gray-400 hover:text-white transition-colors">What We Do</a></li>
              <li><a href={~p"/success-stories"} class="text-gray-400 hover:text-white transition-colors">Success Stories</a></li>
              <li><a href={~p"/news"} class="text-gray-400 hover:text-white transition-colors">News & Updates</a></li>
              <li><a href={~p"/gallery"} class="text-gray-400 hover:text-white transition-colors">Gallery</a></li>
            </ul>
          </div>

          <!-- Contact Info -->
          <div>
            <h3 class="text-lg font-semibold text-green-400 mb-4">Contact Us</h3>
            <ul class="space-y-2">
              <li class="flex items-center text-gray-400">
                <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                House No 8, Chifumbule Road, Woodlands, Lusaka, Zambia
              </li>
              <li class="flex items-center text-gray-400">
                <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
                <a href="mailto:thriveaid1@gmail.com" class="hover:text-white transition-colors">thriveaid1@gmail.com</a>
              </li>
              <li class="flex items-center text-gray-400">
                <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
                </svg>
                <a href="tel:+260963883348" class="hover:text-white transition-colors">+260-963-883-348</a>
              </li>
            </ul>
          </div>
        </div>

        <!-- Bottom Bar -->
        <div class="mt-12 pt-8 border-t border-gray-800">
          <div class="flex flex-col md:flex-row justify-between items-center">
            <p class="text-gray-400 text-sm">
              © <%= current_year %> ThriveAid. All rights reserved.
            </p>
            <div class="flex space-x-6 mt-4 md:mt-0">
              <a href={~p"/contact"} class="text-gray-400 hover:text-white text-sm">Contact Us</a>
              <a href={~p"/donate"} class="text-gray-400 hover:text-white text-sm">Donate</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
