defmodule Thriveaidv2Web.Router do
  use Thriveaidv2Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug Thriveaidv2Web.Plugs.FetchCurrentAdminUser
    plug :put_root_layout, html: {Thriveaidv2Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug Thriveaidv2Web.Plugs.FetchCurrentAdminUser
    plug :put_root_layout, html: {Thriveaidv2Web.Layouts, :admin_root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Thriveaidv2Web do
    pipe_through :browser

    live_session :default, on_mount: [{Thriveaidv2Web.AdminAuth, :mount_current_admin}] do
      live "/", Home.HomePageLive
      live "/gallery", Gallery.GalleryLive
      live "/donate", DonateLive
      live "/about", About.AboutPageLive
      live "/projects", Projects.ProjectsLive
      live "/contact", Contact.ContactLive
      live "/what-we-do", WhatWeDo.WhatWeDoLive
      live "/success-stories", SuccessStories.SuccessStoriesLive
      live "/news", News.NewsLive
      live "/annual-report", AnnualReport.AnnualReportLive, :index
    end
  end

  scope "/admin", Thriveaidv2Web do
    pipe_through :admin_browser

    get "/login", AdminSessionController, :new
    post "/login", AdminSessionController, :create
    get "/logout", AdminSessionController, :delete
    delete "/logout", AdminSessionController, :delete

    live_session :admin, on_mount: [{Thriveaidv2Web.AdminAuth, :require_admin}] do
      live "/", Admin.DashboardLive, :index
    end

    live_session :admin_content,
      on_mount: [
        {Thriveaidv2Web.AdminAuth, :require_admin},
        {Thriveaidv2Web.AdminAuth, {:require_permission, "manage_content"}}
      ] do
      live "/success-stories", Admin.SuccessStoriesLive, :index
      live "/success-stories/new", Admin.SuccessStoriesLive, :new
      live "/success-stories/:id/edit", Admin.SuccessStoriesLive, :edit

      live "/news", Admin.NewsPostsLive, :index
      live "/news/new", Admin.NewsPostsLive, :new
      live "/news/:id/edit", Admin.NewsPostsLive, :edit

      live "/annual-reports", Admin.AnnualReportsLive, :index
      live "/annual-reports/new", Admin.AnnualReportsLive, :new
      live "/annual-reports/:id/edit", Admin.AnnualReportsLive, :edit
    end

    live_session :admin_partners,
      on_mount: [
        {Thriveaidv2Web.AdminAuth, :require_admin},
        {Thriveaidv2Web.AdminAuth, {:require_permission, "manage_partners"}}
      ] do
      live "/partners", Admin.PartnersLive, :index
      live "/partners/new", Admin.PartnersLive, :new
      live "/partners/:id/edit", Admin.PartnersLive, :edit
    end

    live_session :admin_mobile_money_payments,
      on_mount: [
        {Thriveaidv2Web.AdminAuth, :require_admin},
        {Thriveaidv2Web.AdminAuth, {:require_permission, "manage_content"}}
      ] do
      live "/mobile-money-payments", Admin.MobileMoneyPaymentsLive, :index
      live "/mobile-money-payments/:id/edit", Admin.MobileMoneyPaymentsLive, :edit
    end

    live_session :admin_messages,
      on_mount: [
        {Thriveaidv2Web.AdminAuth, :require_admin},
        {Thriveaidv2Web.AdminAuth, {:require_permission, "manage_messages"}}
      ] do
      live "/messages", Admin.MessagesLive, :index
    end

    live_session :admin_donations,
      on_mount: [
        {Thriveaidv2Web.AdminAuth, :require_admin},
        {Thriveaidv2Web.AdminAuth, {:require_permission, "manage_donations"}}
      ] do
      live "/donations", Admin.DonationsLive, :index
      live "/donations/:id", Admin.DonationsLive, :show
      live "/donations/:id/edit", Admin.DonationsLive, :edit
      live "/donations/:id/print", Admin.DonationsLive, :print
    end

    live_session :admin_users_mgmt,
      on_mount: [
        {Thriveaidv2Web.AdminAuth, :require_admin},
        {Thriveaidv2Web.AdminAuth, {:require_permission, "manage_admins"}}
      ] do
      live "/admin-users", Admin.AdminUsersLive, :index
      live "/admin-users/new", Admin.AdminUsersLive, :new
      live "/admin-users/:id/edit", Admin.AdminUsersLive, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Thriveaidv2Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:thriveaidv2, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Thriveaidv2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
