defmodule Thriveaidv2Web.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use Thriveaidv2Web, :controller` and
  `use Thriveaidv2Web, :live_view`.
  """
  use Thriveaidv2Web, :html

  import Thriveaidv2Web.Components.Layouts.TopNav
  import Thriveaidv2Web.Components.Layouts.Footer.FooterComponent
  embed_templates "layouts/*"
end
