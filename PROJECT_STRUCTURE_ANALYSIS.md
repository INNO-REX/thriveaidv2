# Project Structure Analysis: .heex and .ex Files

## Overview
This is a Phoenix LiveView application with a clear separation between:
- **Public-facing pages** (using `:live_view`)
- **Admin pages** (using `:admin_live_view`)
- **Traditional controllers** (for non-LiveView pages)

---

## Directory Structure

### Main Application Structure
```
lib/
├── thriveaidv2/              # Business logic (contexts, schemas)
│   ├── accounts/
│   ├── content/
│   └── inbox/
│
└── thriveaidv2_web/          # Web layer
    ├── live/                 # LiveView modules
    ├── controllers/          # Traditional controllers
    ├── components/           # Reusable components
    └── plugs/                # Custom plugs
```

---

## LiveView Structure Patterns

### 1. Public LiveViews (`lib/thriveaidv2_web/live/`)

**Pattern:** Each LiveView has its own subdirectory with matching `.ex` and `.heex` files.

#### Structure:
```
live/
├── about_page/
│   ├── about_page_live.ex          # Module: Thriveaidv2Web.About.AboutPageLive
│   └── about_page_live.html.heex   # Template
├── annual_report/
│   ├── annual_report_live.ex
│   └── annual_report_live.html.heex
├── contact/
│   ├── contact_live.ex
│   └── contact_live.html.heex
├── donate_live.ex                  # Exception: flat structure
├── donate_live.html.heex
├── gallery/
│   ├── gallery_live.ex
│   └── gallery_live.html.heex
├── home_page/
│   ├── home_page_live.ex
│   └── home_page_live.html.heex
├── news/
│   ├── news_live.ex
│   └── news_live.html.heex
├── projects/
│   ├── projects_live.ex
│   └── projects_live.html.heex
├── success_stories/
│   ├── success_stories_live.ex
│   └── success_stories_live.html.heex
└── what_we_do/
    ├── what_we_do_live.ex
    └── what_we_do_live.html.heex
```

**Characteristics:**
- All use `use Thriveaidv2Web, :live_view`
- Layout: `{Thriveaidv2Web.Layouts, :app}` (defined in `thriveaidv2_web.ex`)
- Module naming: `Thriveaidv2Web.{Namespace}.{Name}Live`
- File naming: `{snake_case_name}_live.ex` and `{snake_case_name}_live.html.heex`

**Exception:**
- `donate_live.ex` and `donate_live.html.heex` are in the root `live/` directory (not in a subdirectory)

---

### 2. Admin LiveViews (`lib/thriveaidv2_web/live/admin/`)

**Pattern:** All admin LiveViews are in a flat structure within the `admin/` directory.

#### Structure:
```
live/admin/
├── admin_users_live.ex
├── admin_users_live.html.heex
├── airtel_payment_live.ex          # ⚠️ MISSING .heex file
├── annual_reports_live.ex
├── annual_reports_live.html.heex
├── dashboard_live.ex
├── dashboard_live.html.heex
├── donations_live.ex
├── donations_live.html.heex
├── messages_live.ex
├── messages_live.html.heex
├── mobile_money_payments_live.ex
├── mobile_money_payments_live.html.heex
├── news_posts_live.ex
├── news_posts_live.html.heex
├── partners_live.ex
├── partners_live.html.heex
├── success_stories_live.ex
└── success_stories_live.html.heex
```

**Characteristics:**
- All use `use Thriveaidv2Web, :admin_live_view`
- Layout: `{Thriveaidv2Web.Layouts, :admin}` (defined in `thriveaidv2_web.ex`)
- Module naming: `Thriveaidv2Web.Admin.{Name}Live`
- File naming: `{snake_case_name}_live.ex` and `{snake_case_name}_live.html.heex`

**Issues Found:**
- ⚠️ `airtel_payment_live.ex` exists but is **empty** (only 1 line)
- ⚠️ `airtel_payment_live.html.heex` is **missing**

---

## Controller Structure Patterns

### Traditional Controllers (`lib/thriveaidv2_web/controllers/`)

**Pattern:** Controllers use a separate HTML view module pattern.

#### Structure:
```
controllers/
├── admin_session_controller.ex
├── admin_session_html.ex              # View module
├── admin_session_html/
│   └── new.html.heex                  # Template
├── page_controller.ex
├── page_html.ex                       # View module
├── page_html/
│   └── home.html.heex                 # Template
├── error_html.ex
└── error_json.ex
```

**Characteristics:**
- Controllers: `{name}_controller.ex`
- View modules: `{name}_html.ex`
- Templates: `{name}_html/{action}.html.heex`
- Used for non-LiveView pages (login, error pages, etc.)

---

## Component Structure

### Layouts (`lib/thriveaidv2_web/components/layouts/`)

```
components/layouts/
├── layouts.ex                         # Main layouts module
├── admin_root.html.heex              # Admin root layout
├── admin.html.heex                    # Admin app layout
├── app.html.heex                      # Public app layout
├── root.html.heex                     # Root layout
├── top_nav.ex                         # Top navigation component
├── footer/
│   └── footer_component.ex            # Footer component
└── partners_component.ex              # Partners component
```

**Pattern:**
- Layout templates use `.html.heex` extension
- Component modules use `.ex` extension
- `layouts.ex` uses `embed_templates "layouts/*"` to embed all layout templates

---

## Naming Conventions

### Module Names
- **Public LiveViews:** `Thriveaidv2Web.{Namespace}.{Name}Live`
  - Example: `Thriveaidv2Web.Contact.ContactLive`
- **Admin LiveViews:** `Thriveaidv2Web.Admin.{Name}Live`
  - Example: `Thriveaidv2Web.Admin.AdminUsersLive`
- **Controllers:** `Thriveaidv2Web.{Name}Controller`
  - Example: `Thriveaidv2Web.AdminSessionController`

### File Names
- **LiveView modules:** `{snake_case_name}_live.ex`
- **LiveView templates:** `{snake_case_name}_live.html.heex`
- **Controller modules:** `{snake_case_name}_controller.ex`
- **View modules:** `{snake_case_name}_html.ex`
- **View templates:** `{snake_case_name}_html/{action}.html.heex`

---

## File Pairing Rules

### LiveViews
✅ **Rule:** Every `.ex` LiveView file should have a corresponding `.html.heex` template file.

**Exceptions:**
- Some LiveViews might render only components (no template needed)
- But this is rare and should be documented

### Current Status:
- ✅ Most LiveViews have matching `.heex` files
- ⚠️ `airtel_payment_live.ex` is empty and missing its `.heex` file

---

## Router Patterns

### Public Routes
```elixir
live_session :default do
  live "/", Home.HomePageLive
  live "/contact", Contact.ContactLive
  # ... etc
end
```

### Admin Routes
```elixir
live_session :admin_content do
  live "/success-stories", Admin.SuccessStoriesLive, :index
  live "/success-stories/new", Admin.SuccessStoriesLive, :new
  live "/success-stories/:id/edit", Admin.SuccessStoriesLive, :edit
end
```

**Pattern:**
- Routes use `live` macro for LiveView routes
- Admin routes are grouped by permission level
- Actions (`:index`, `:new`, `:edit`) are specified for CRUD operations

---

## Summary Statistics

### File Counts:
- **Total .ex files:** 58
- **Total .heex files:** 25
- **LiveView .ex files:** ~19 (public) + ~11 (admin) = ~30
- **LiveView .heex files:** ~10 (public) + ~10 (admin) = ~20

### Missing Files:
1. ⚠️ `airtel_payment_live.html.heex` (module exists but is empty)

### Incomplete Files:
1. ⚠️ `airtel_payment_live.ex` (empty file, needs implementation)

---

## Recommendations

### 1. Complete `airtel_payment_live.ex`
   - Implement the LiveView module
   - Create the corresponding `airtel_payment_live.html.heex` template
   - Add route in `router.ex` if needed

### 2. Consistency
   - Consider moving `donate_live.ex` into a `donate/` subdirectory for consistency
   - Or document why it's an exception

### 3. Documentation
   - Document any LiveViews that intentionally don't have templates
   -poiu Add module documentation for complex LiveViews

### 4. Organization
   - The current structure is well-organized
   - Admin LiveViews could potentially be organized into subdirectories if they grow:
     ```
     admin/
       ├── content/
       │   ├── success_stories_live.ex
       │   └── news_posts_live.ex
       ├── users/
       │   └── admin_users_live.ex
       └── payments/
           ├── donations_live.ex
           └── mobile_money_payments_live.ex
     ```

---

## Key Patterns Summary

1. **LiveView Pairing:** `.ex` + `.html.heex` files are paired by name
2. **Directory Structure:** Public LiveViews use subdirectories; Admin LiveViews are flat
3. **Naming:** Consistent snake_case for files, PascalCase for modules
4. **Layouts:** Different layouts for public (`:app`) vs admin (`:admin`)
5. **Controllers:** Use separate view modules (`*_html.ex`) for templates
rweq