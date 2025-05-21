defmodule Thriveaidv2Web.Components.Layouts.TopNav do
  use Phoenix.Component

  def top_nav(assigns) do
    ~H"""
    <nav class="bg-white shadow-md fixed w-full z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <!-- Logo and Brand Name -->
          <div class="flex items-center">
            <a href="/" class="flex items-center">
              <span class="text-2xl font-bold text-green-600">ThriveAid</span>
            </a>
          </div>

          <!-- Desktop Navigation -->
          <div class="hidden md:flex items-center space-x-8">
            <a href="/" class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition">Home</a>
            <a href="/about" class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition">About Us</a>
            <a href="/gallery" class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition">Gallery</a>
            <a href="/projects" class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition">Projects</a>
            <a href="/contact" class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition">Contact</a>
            <a href="/donate" class="bg-green-600 text-white hover:bg-green-700 px-4 py-2 rounded-full text-sm font-medium transition">Donate Now</a>
          </div>

          <!-- Mobile Navigation Button -->
          <div class="md:hidden flex items-center">
            <button
              type="button"
              class="text-gray-700 hover:text-green-600"
              onclick="document.getElementById('mobile-menu').classList.toggle('hidden')"
            >
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Mobile Navigation Menu -->
        <div class="hidden md:hidden" id="mobile-menu">
          <div class="px-2 pt-2 pb-3 space-y-1">
            <a href="/" class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition">Home</a>
            <a href="/about" class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition">About Us</a>
            <a href="/gallery" class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition">Gallery</a>
            <a href="/projects" class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition">Projects</a>
            <a href="/contact" class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition">Contact</a>
            <a href="/donate" class="block bg-green-600 text-white hover:bg-green-700 px-4 py-2 rounded-full text-base font-medium transition text-center mt-4">Donate Now</a>
          </div>
        </div>
      </div>
    </nav>

    <!-- Spacer to prevent content from hiding under fixed nav -->
    <div class="h-16"></div>
    """
  end
end
