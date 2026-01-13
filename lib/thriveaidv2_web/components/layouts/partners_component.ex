defmodule Thriveaidv2Web.Components.Layouts.PartnersComponent do
  use Phoenix.Component

  attr :partners, :list, default: []

  def partners_section(assigns) do
    ~H"""
    <!-- Enhanced Partners Section -->
    <div class="py-12 md:py-20 lg:py-24 bg-gray-50 relative overflow-hidden">
      <!-- Decorative background elements -->
      <div class="absolute top-1/2 left-0 -translate-y-1/2 -translate-x-1/4 w-[500px] h-[500px] bg-gradient-to-r from-green-100 to-transparent rounded-full blur-3xl opacity-60" aria-hidden="true"></div>
      <div class="absolute top-1/2 right-0 -translate-y-1/2 translate-x-1/4 w-[500px] h-[500px] bg-gradient-to-l from-teal-100 to-transparent rounded-full blur-3xl opacity-60" aria-hidden="true"></div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center">
          <h2 class="text-3xl md:text-4xl font-bold text-gray-900 animate-fade-in">
            Our Valued <em class="text-green-600">Partners</em>
          </h2>
          <p class="mt-4 max-w-2xl mx-auto text-lg text-gray-600 animate-fade-in delay-300">
            We are proud to collaborate with organizations that share our vision for a brighter future. Together, we amplify our impact.
          </p>
        </div>
      </div>

      <!-- Infinite Scrolling Marquee -->
      <div :if={@partners != []} class="mt-12 md:mt-16 partners-marquee" x-data="{}" x-init="$el.setAttribute('data-animated', true)">
        <div class="partners-track">
          <!-- First set of logos -->
          <div :for={partner <- @partners} class="partner-logo-item">
            <a :if={partner.website_url} href={partner.website_url} target="_blank" rel="noopener noreferrer" class="block w-full h-full flex items-center justify-center">
              <img src={partner.logo_path} alt={partner.name} />
            </a>
            <img :if={!partner.website_url} src={partner.logo_path} alt={partner.name} />
          </div>

          <!-- Duplicate set for seamless looping -->
          <div :for={partner <- @partners} class="partner-logo-item">
            <a :if={partner.website_url} href={partner.website_url} target="_blank" rel="noopener noreferrer" class="block w-full h-full flex items-center justify-center">
              <img src={partner.logo_path} alt={partner.name} />
            </a>
            <img :if={!partner.website_url} src={partner.logo_path} alt={partner.name} />
          </div>
        </div>
      </div>
    </div>

    <style>
      @keyframes fade-in {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
      }

      .animate-fade-in {
        animation: fade-in 1s ease-out forwards;
      }

      .delay-300 { animation-delay: 300ms; }

      /* Updated styles for the enhanced Partners section (Full Color) */
      .partners-marquee {
        width: 100%;
        max-width: 100vw;
        overflow: hidden;
        position: relative;
        /* Add a fade effect on the edges */
        -webkit-mask-image: linear-gradient(to right, transparent, black 10%, black 90%, transparent);
        mask-image: linear-gradient(to right, transparent, black 10%, black 90%, transparent);
      }

      .partners-track {
        display: flex;
        align-items: center;
        gap: 2rem; /* space between logos */
        width: max-content;
        flex-shrink: 0; /* Prevent the track from shrinking */
        animation: scroll-left 30s linear infinite;
      }

      /* Pause animation on hover */
      .partners-marquee:hover .partners-track {
        animation-play-state: paused;
      }

      @keyframes scroll-left {
        0% {
          transform: translateX(0);
        }
        100% {
          /* Move the track left by the width of one full set of logos */
          transform: translateX(-50%);
        }
      }

      .partner-logo-item {
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 1rem;
        background-color: white;
        border-radius: 0.75rem; /* 12px */
        border: 1px solid #e5e7eb; /* gray-200 */
        box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.05), 0 2px 4px -2px rgb(0 0 0 / 0.05);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        height: 100px; /* Consistent height for all cards */
        width: 200px; /* Consistent width */
      }

      .partner-logo-item img {
        max-width: 100%;
        max-height: 60px; /* Adjust as needed for your logos */
        object-fit: contain;
        transition: transform 0.3s ease; /* We can add a subtle scale on hover */
      }

      /* Hover effects */
      .partner-logo-item:hover {
        transform: translateY(-8px);
        box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
      }

      .partner-logo-item:hover img {
        transform: scale(1.05);
      }
    </style>
    """
  end
end
