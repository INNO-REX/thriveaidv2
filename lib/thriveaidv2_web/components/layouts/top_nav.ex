defmodule Thriveaidv2Web.Components.Layouts.TopNav do
  use Thriveaidv2Web, :html

  def top_nav(assigns) do
    assigns = assign_new(assigns, :current_admin_user, fn -> nil end)

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
            <a href="/" class={"text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition #{if @current_page == "home", do: "text-green-600 font-semibold"}"}>Home</a>
            <a href="/about" class={"text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition #{if @current_page == "about", do: "text-green-600 font-semibold"}"}>About Us</a>
            <a href="/what-we-do" class={"text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition #{if @current_page == "what-we-do", do: "text-green-600 font-semibold"}"}>What We Do</a>
            <a href="/success-stories" class={"text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition #{if @current_page == "success-stories", do: "text-green-600 font-semibold"}"}>Success Stories</a>
            <a href="/news" class={"text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition #{if @current_page == "news", do: "text-green-600 font-semibold"}"}>News Updates</a>
            <a href="/contact" class={"text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition #{if @current_page == "contact", do: "text-green-600 font-semibold"}"}>Contact Us</a>
            <.link
              :if={@current_admin_user}
              href={~p"/admin"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition"
            >
              Admin
            </.link>
            <.link
              :if={@current_admin_user}
              href={~p"/admin/logout"}
              class="text-gray-700 hover:text-green-600 px-3 py-2 text-sm font-medium transition"
            >
              Logout
            </.link>
            <a href="/donate" class={"bg-green-600 text-white hover:bg-green-700 px-4 py-2 rounded-full text-sm font-medium transition #{if @current_page == "donate", do: "bg-green-700 shadow-lg"}"}>Donate Now</a>
             <.link
              :if={!@current_admin_user}
              href={~p"/admin/login"}
              class="rounded-full bg-gray-900 text-white hover:bg-gray-800 px-4 py-2 text-sm font-semibold transition"
            >
              Login
            </.link>         
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
            <a href="/" class={"block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition #{if @current_page == "home", do: "text-green-600 font-semibold"}"}>Home</a>
            <a href="/about" class={"block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition #{if @current_page == "about", do: "text-green-600 font-semibold"}"}>About Us</a>
            <a href="/what-we-do" class={"block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition #{if @current_page == "what-we-do", do: "text-green-600 font-semibold"}"}>What We Do</a>
            <a href="/success-stories" class={"block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition #{if @current_page == "success-stories", do: "text-green-600 font-semibold"}"}>Success Stories</a>
            <a href="/news" class={"block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition #{if @current_page == "news", do: "text-green-600 font-semibold"}"}>News Updates</a>
            <a href="/contact" class={"block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition #{if @current_page == "contact", do: "text-green-600 font-semibold"}"}>Contact Us</a>
            <.link
              :if={@current_admin_user}
              href={~p"/admin"}
              class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition"
            >
              Admin
            </.link>
            <.link
              :if={@current_admin_user}
              href={~p"/admin/logout"}
              class="block text-gray-700 hover:text-green-600 px-3 py-2 text-base font-medium transition"
            >
              Logout
            </.link>
            <.link
              :if={!@current_admin_user}
              href={~p"/admin/login"}
              class="block bg-gray-900 text-white hover:bg-gray-800 px-4 py-2 rounded-full text-base font-semibold transition text-center mt-2"
            >
              Admin Login
            </.link>
            <a href="/donate" class={"block bg-green-600 text-white hover:bg-green-700 px-4 py-2 rounded-full text-base font-medium transition text-center mt-2 #{if @current_page == "donate", do: "bg-green-700 shadow-lg"}"}>Donate Now</a>
          </div>
        </div>
      </div>
    </nav>

    <!-- Spacer to prevent content from hiding under fixed nav -->
    <div class="h-16"></div>
    """
  end
end
