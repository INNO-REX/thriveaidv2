defmodule Thriveaidv2.Content do
  @moduledoc """
  Content management for ThriveAid: Success Stories and News Posts.
  """

  import Ecto.Query, warn: false

  alias Thriveaidv2.Repo

  alias Thriveaidv2.Content.AnnualReport
  alias Thriveaidv2.Content.Donation
  alias Thriveaidv2.Content.MobileMoneyPayment
  alias Thriveaidv2.Content.NewsPost
  alias Thriveaidv2.Content.Partner
  alias Thriveaidv2.Content.SuccessStory

  ## Success Stories

  def list_success_stories do
    Repo.all(from s in SuccessStory, order_by: [desc: s.inserted_at])
  end

  def list_published_success_stories do
    Repo.all(
      from s in SuccessStory,
        where: s.is_published == true,
        order_by: [desc: s.published_at, desc: s.inserted_at]
    )
  end

  def get_success_story!(id), do: Repo.get!(SuccessStory, id)

  def create_success_story(attrs \\ %{}) do
    %SuccessStory{}
    |> SuccessStory.changeset(attrs)
    |> Repo.insert()
  end

  def update_success_story(%SuccessStory{} = story, attrs) do
    story
    |> SuccessStory.changeset(attrs)
    |> Repo.update()
  end

  def delete_success_story(%SuccessStory{} = story), do: Repo.delete(story)

  def change_success_story(%SuccessStory{} = story, attrs \\ %{}) do
    SuccessStory.changeset(story, attrs)
  end

  ## News Posts

  def list_news_posts do
    Repo.all(from n in NewsPost, order_by: [desc: n.inserted_at])
  end

  def list_published_news_posts do
    Repo.all(
      from n in NewsPost,
        where: n.is_published == true,
        order_by: [desc: n.published_at, desc: n.inserted_at]
    )
  end

  def get_news_post!(id), do: Repo.get!(NewsPost, id)

  def create_news_post(attrs \\ %{}) do
    %NewsPost{}
    |> NewsPost.changeset(attrs)
    |> Repo.insert()
  end

  def update_news_post(%NewsPost{} = post, attrs) do
    post
    |> NewsPost.changeset(attrs)
    |> Repo.update()
  end

  def delete_news_post(%NewsPost{} = post), do: Repo.delete(post)

  def change_news_post(%NewsPost{} = post, attrs \\ %{}) do
    NewsPost.changeset(post, attrs)
  end

  ## Partners

  def list_partners do
    Repo.all(from p in Partner, order_by: [asc: p.display_order, desc: p.inserted_at])
  end

  def list_active_partners do
    Repo.all(
      from p in Partner,
        where: p.is_active == true,
        order_by: [asc: p.display_order, desc: p.inserted_at]
    )
  end

  def get_partner!(id), do: Repo.get!(Partner, id)

  def create_partner(attrs \\ %{}) do
    %Partner{}
    |> Partner.changeset(attrs)
    |> Repo.insert()
  end

  def update_partner(%Partner{} = partner, attrs) do
    partner
    |> Partner.changeset(attrs)
    |> Repo.update()
  end

  def delete_partner(%Partner{} = partner), do: Repo.delete(partner)

  def change_partner(%Partner{} = partner, attrs \\ %{}) do
    Partner.changeset(partner, attrs)
  end

  ## Mobile Money Payment Settings

  def list_mobile_money_payments do
    Repo.all(from m in MobileMoneyPayment, order_by: [asc: m.method_name])
  end

  def get_mobile_money_payment!(id), do: Repo.get!(MobileMoneyPayment, id)

  def get_mobile_money_payment_by_method(method_name) do
    Repo.one(from m in MobileMoneyPayment, where: m.method_name == ^method_name)
  end

  def get_or_create_mobile_money_payment(method_name, default_attrs \\ %{}) do
    case get_mobile_money_payment_by_method(method_name) do
      nil ->
        attrs = Map.merge(%{
          phone_number: "+260 977 123 456",
          account_name: "ThriveAid Foundation",
          payment_steps_html: format_default_steps()
        }, default_attrs)
        |> Map.put(:method_name, method_name)

        %MobileMoneyPayment{}
        |> MobileMoneyPayment.changeset(attrs)
        |> Repo.insert!()

      payment ->
        payment
    end
  end

  def create_mobile_money_payment(attrs \\ %{}) do
    %MobileMoneyPayment{}
    |> MobileMoneyPayment.changeset(attrs)
    |> Repo.insert()
  end

  def update_mobile_money_payment(%MobileMoneyPayment{} = payment, attrs) do
    payment
    |> MobileMoneyPayment.changeset(attrs)
    |> Repo.update()
  end

  def delete_mobile_money_payment(%MobileMoneyPayment{} = payment) do
    Repo.delete(payment)
  end

  def change_mobile_money_payment(%MobileMoneyPayment{} = payment, attrs \\ %{}) do
    MobileMoneyPayment.changeset(payment, attrs)
  end

  # Backward compatibility - keep for existing code
  def get_airtel_payment do
    get_or_create_mobile_money_payment("airtel")
  end

  def update_airtel_payment(attrs) do
    payment = get_airtel_payment()
    update_mobile_money_payment(payment, Map.put(attrs, "method_name", "airtel"))
  end

  def change_airtel_payment(attrs \\ %{}) do
    payment = get_airtel_payment()
    change_mobile_money_payment(payment, Map.put(attrs, "method_name", "airtel"))
  end

  ## Donations

  def create_donation(attrs \\ %{}) do
    %Donation{}
    |> Donation.changeset(attrs)
    |> Repo.insert()
  end

  def get_donation!(id), do: Repo.get!(Donation, id)

  def list_donations do
    Repo.all(from d in Donation, order_by: [desc: d.inserted_at])
  end

  def count_pending_donations do
    Repo.aggregate(
      from(d in Donation, where: d.status == "pending"),
      :count,
      :id
    )
  end

  def list_donations_paginated(opts \\ []) do
    import Ecto.Query

    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    status = Keyword.get(opts, :status)
    payment_method = Keyword.get(opts, :payment_method)
    search = Keyword.get(opts, :search)
    date_from = Keyword.get(opts, :date_from)
    date_to = Keyword.get(opts, :date_to)

    query = from d in Donation

    # Apply filters
    query =
      if status && status != "all" do
        from d in query, where: d.status == ^status
      else
        query
      end

    query =
      if payment_method && payment_method != "all" do
        from d in query, where: d.payment_method == ^payment_method
      else
        query
      end

    query =
      if search && String.trim(search) != "" do
        search_term = "%#{String.trim(search)}%"
        from d in query,
          where:
            ilike(d.donor_name, ^search_term) or
              ilike(d.donor_email, ^search_term) or
              ilike(d.donor_phone, ^search_term)
      else
        query
      end

    query =
      if date_from do
        # Convert date to beginning of day datetime
        datetime_from = DateTime.new!(date_from, ~T[00:00:00], "Etc/UTC")
        from d in query, where: d.inserted_at >= ^datetime_from
      else
        query
      end

    query =
      if date_to do
        # Convert date to end of day datetime
        datetime_to = DateTime.new!(date_to, ~T[23:59:59], "Etc/UTC")
        from d in query, where: d.inserted_at <= ^datetime_to
      else
        query
      end

    # Get total count
    total = Repo.aggregate(query, :count, :id)

    # Calculate stats for ALL filtered results (not just current page)
    all_filtered = Repo.all(from d in query, order_by: [desc: d.inserted_at])
    successful_donations = Enum.reject(all_filtered, &(&1.status == "failed"))
    total_amount = Enum.sum(Enum.map(successful_donations, & &1.amount))
    pending_count = Enum.count(all_filtered, &(&1.status == "pending"))
    completed_count = Enum.count(all_filtered, &(&1.status == "completed"))
    failed_count = Enum.count(all_filtered, &(&1.status == "failed"))

    # Apply pagination and ordering for current page
    query =
      from d in query,
        order_by: [desc: d.inserted_at],
        limit: ^per_page,
        offset: ^((page - 1) * per_page)

    donations = Repo.all(query)

    %{
      entries: donations,
      page_number: page,
      page_size: per_page,
      total_entries: total,
      total_pages: ceil(total / per_page),
      total_amount: total_amount,
      pending_count: pending_count,
      completed_count: completed_count,
      failed_count: failed_count
    }
  end

  def update_donation(%Donation{} = donation, attrs) do
    donation
    |> Donation.changeset(attrs)
    |> Repo.update()
  end

  def delete_donation(%Donation{} = donation) do
    Repo.delete(donation)
  end

  def change_donation(%Donation{} = donation, attrs \\ %{}) do
    Donation.changeset(donation, attrs)
  end

  ## Annual Reports

  def list_annual_reports do
    Repo.all(from a in AnnualReport, order_by: [desc: a.year])
  end

  def list_published_annual_reports do
    Repo.all(
      from a in AnnualReport,
        where: a.is_published == true,
        order_by: [desc: a.year]
    )
  end

  def get_annual_report!(id), do: Repo.get!(AnnualReport, id)

  def get_annual_report_by_year(year) do
    Repo.one(
      from a in AnnualReport,
        where: a.year == ^year and a.is_published == true
    )
  end

  def get_latest_published_annual_report do
    Repo.one(
      from a in AnnualReport,
        where: a.is_published == true,
        order_by: [desc: a.year],
        limit: 1
    )
  end

  def create_annual_report(attrs \\ %{}) do
    %AnnualReport{}
    |> AnnualReport.changeset(attrs)
    |> Repo.insert()
  end

  def update_annual_report(%AnnualReport{} = report, attrs) do
    report
    |> AnnualReport.changeset(attrs)
    |> Repo.update()
  end

  def delete_annual_report(%AnnualReport{} = report), do: Repo.delete(report)

  def change_annual_report(%AnnualReport{} = report, attrs \\ %{}) do
    AnnualReport.changeset(report, attrs)
  end

  def format_default_steps do
    steps = [
      "Dial *123# on your Airtel phone",
      "Select Send Money or Pay Bill from the menu",
      "Enter the phone number: PHONENUMBER",
      "Enter the amount: KAMOUNT",
      "Verify the recipient name shows as: ACCOUNTNAME",
      "Enter your PIN to confirm the transaction"
    ]
    
    steps_html = 
      steps
      |> Enum.with_index(1)
      |> Enum.map(fn {step, index} ->
        formatted_step = 
          step
          |> String.replace("PHONENUMBER", "<strong class=\"text-red-400\">PHONENUMBER</strong>")
          |> String.replace("KAMOUNT", "<strong class=\"text-red-400\">KAMOUNT</strong>")
          |> String.replace("ACCOUNTNAME", "<strong class=\"text-white\">ACCOUNTNAME</strong>")
        
        """
        <li class="flex items-start">
          <span class="flex-shrink-0 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center text-white font-semibold mr-3 mt-0.5">#{index}</span>
          <span>#{formatted_step}</span>
        </li>
        """
      end)
      |> Enum.join("\n")
    
    "<ol class=\"space-y-3 text-gray-300\">\n#{steps_html}\n</ol>"
  end
end


