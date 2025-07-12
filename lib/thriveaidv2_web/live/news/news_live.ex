defmodule Thriveaidv2Web.News.NewsLive do
  use Thriveaidv2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    news_articles = [
      %{
        id: 1,
        title: "Empowering Young People Through Computer Literacy: A Successful Initiative by Thrive Aid",
        date: "2024",
        image: "/images/news/news1/2.jpg",
        summary: "Thrive Aid launched a transformative Computer Literacy Program aimed at bridging the digital divide for 17 young people. The program, held at USAID Open Spaces (Digi Hub), provided essential digital skills to youth, offering them a brighter future in our tech-driven world.",
        content: "Thrive Aid launched a transformative Computer Literacy Program aimed at bridging the digital divide for 17 young people. The program, held at USAID Open Spaces (Digi Hub), provided essential digital skills to youth, offering them a brighter future in our tech-driven world.",
        full_content: """
        <h4>Empowering Young People Through Computer Literacy: A Successful Initiative by Thrive Aid</h4>
        <h6><b>Program Overview</b></h6>
        <p>This holiday season, Thrive Aid launched a transformative Computer Literacy Program as part of our academic support and mentorship initiatives. The program, aimed at bridging the digital divide, was held at USAID open Spaces (Digi Hub). 17 young people from Fountain of Hope Orphanage and Breakthrough Youth Generation (BYG) were trained. It sought to equip young people with essential digital skills, offering them a brighter future in our increasingly tech-driven world.</p>

        <h6><b>First Steps into the Digital World</b></h6>
        <p>From the first day, the enthusiasm was palpable. Participants, eager to learn, were introduced to basic computer skills, including how to navigate the internet safely, use essential software tools such as Microsoft Word and PowerPoint, and understanding the basic computer hardware. For many of these young people, it was their first time interacting with computers, making the experience both exciting and eye-opening. The program provided them with not just technical knowledge, but also the confidence to explore the digital realm independently.</p>

        <h6><b>Inspirational Guest Speakers</b></h6>
        <p>Week two of the program marked a significant highlight. We were honoured to host two remarkable guest speakers: Chikondi Banda, a renowned 3D artist, and Edwin Kapesa, one of Africa's leading game developers and the CEO of Chroma Pixel Games. Their presence was nothing short of inspirational. Since 2021, Chroma Pixel Games has been making waves in the African gaming industry, and Edwin's insights into coding and game development captivated the young minds. His message of passion and perseverance resonated deeply, igniting a newfound interest in technology and game development among our learners.</p>

        <h6><b>Dedicated Training and Support</b></h6>
        <p>Throughout the program, our dedicated trainer, Sichilima Mulenga, a skilled software engineer, played a pivotal role in imparting valuable skills to the participants. His patience and expertise ensured that every learner, regardless of their starting point, was able to grasp the concepts and put them into practice.</p>

        <h6><b>Partnership and Gratitude</b></h6>
        <p>We extend our heartfelt thanks to Sichilima, as well as to the USAID Open Spaces Zambia DIGI-HUB for providing us with the space needed to conduct our training sessions. Their support was crucial in making this program a success.</p>

        <h6><b>Impact and Future</b></h6>
        <p>As we reflect on the progress made over these weeks, we are filled with pride and optimism. The road to computer literacy may have just begun, but the impact is already evident. These young people are now better prepared to face the future, with doors to endless opportunities opened wide. We look forward to continuing this journey and reaching even more youths, empowering them to transform their lives through digital education.</p>

        <p>Stay tuned for more updates as we continue to make strides in transforming lives through technology and education.</p>

        <p><strong>#ComputerLiteracy #Education #Mentorship #ThriveAid #TransformingLives</strong></p>
        """,
        images: [
          "/images/news/news1/6.jpg",
          "/images/news/news1/8.jpg",
          "/images/news/news1/3.jpg",
          "/images/news/news1/9.jpg"
        ]
      },
      %{
        id: 2,
        title: "Thrive Aid and Ministry of Community Development Join Forces in Street Children Awareness Campaign",
        date: "August 2024",
        image: "/images/news/news2/4.jpg",
        summary: "In a significant step towards tackling the issue of street children in Lusaka, Thrive Aid collaborated with the Ministry of Community Development and Social Services' Child Development Department to launch a vital public awareness campaign.",
        content: "In a significant step towards tackling the issue of street children in Lusaka, Thrive Aid collaborated with the Ministry of Community Development and Social Services' Child Development Department to launch a vital public awareness campaign.",
        full_content: """
        <h4>Thrive Aid and Ministry of Community Development Join Forces in Street Children Awareness Campaign</h4>
        <h6><b>Campaign Overview</b></h6>
        <p>In a significant step towards tackling the issue of street children in Lusaka, Thrive Aid collaborated with the Ministry of Community Development and Social Services' Child Development Department to launch a vital public awareness campaign. This outreach program, held on 15th August 2024, aimed to address a critical issue that affects the lives of many children living on the streets—alms-giving.</p>

        <h6><b>Addressing the Root Cause</b></h6>
        <p>The campaign focused on educating the public about the detrimental effects of giving alms to street children. Research indicates that this practice not only perpetuates streetism but also inadvertently supports drug addiction among them. By highlighting these issues, the campaign sought to encourage more sustainable and impactful ways to assist these children.</p>

        <h6><b>Comprehensive Approach</b></h6>
        <p>During the event, both Thrive Aid and the Ministry of Community Development emphasized the need for a comprehensive approach to solving the problem of street children. Addressing this complex issue requires the concerted efforts of all stakeholders, including government bodies, non-profit organizations, and the community at large.</p>

        <h6><b>Public Engagement</b></h6>
        <p>The public was urged to rethink their approach to supporting street children and to consider alternative methods that can provide more lasting and meaningful help. The campaign successfully engaged the public and prompted them to reflect on the broader implications of their actions.</p>

        <h6><b>Impact and Future Steps</b></h6>
        <p>The success of this awareness campaign marks a significant step forward in our shared mission to support and uplift street children. It demonstrated that through collective efforts and informed action, we can move closer to finding effective solutions and making a positive impact.</p>

        <p>Together, we can create change and build a brighter future for these vulnerable children. As we continue to collaborate and advocate for their well-being, we reaffirm our commitment to transforming lives and fostering a supportive community.</p>

        <p><strong>#StreetChildren #MentalHealthAwareness #ThriveAid #TransformingLives</strong></p>
        """,
        images: [
          "/images/news/news2/1.jpg",
          "/images/news/news2/8.jpg",
          "/images/news/news2/3.jpg",
          "/images/news/news2/9.jpg"
        ]
      },
      %{
        id: 3,
        title: "Thrive Aid Brings Hope to the Streets: Mental Health and Adolescent Health Outreach for Young People",
        date: "September 2024",
        image: "/images/news/news3/1.jpg",
        summary: "On September 7th, Thrive Aid organized a Mental Health Outreach event that provided vital support to children living on the streets and those residing at the Fountain of Hope Orphanage.",
        content: "On September 7th, Thrive Aid organized a Mental Health Outreach event that provided vital support to children living on the streets and those residing at the Fountain of Hope Orphanage.",
        full_content: """
        <h4>Thrive Aid Brings Hope to the Streets: Mental Health and Adolescent Health Outreach for Young People</h4>
        <h6><b>Event Overview</b></h6>
        <p>On September 7th, Thrive Aid organized a Mental Health Outreach event that provided vital support to children living on the streets and those residing at the Fountain of Hope Orphanage. Young people from diverse backgrounds and challenging circumstances came together in a safe, supportive environment where they could learn, share, and receive counseling on essential topics like mental health, sexual and reproductive health (SRH), and substance abuse.</p>

        <h6><b>Mobilization and Welcome</b></h6>
        <p>The event began at 11:30 a.m. and lasted until 2:00 p.m. We started with mobilizing street-connected youths from locations around the city, including the Nipa traffic lights, Levy Junction flyover bridge, and various other spots across town. With every young person welcomed warmly, the outreach set the stage for impactful conversations, education, and meaningful connection.</p>

        <h6><b>Mental Health Awareness</b></h6>
        <p>The event opened with a presentation on mental health, covering topics like suicide, anxiety, depression, and factors that contribute to these issues. Through interactive discussions, facilitators encouraged the young people to ask questions and explore how mental health affects their lives. The session provided a general awareness of mental health, aiming to reduce stigma while also equipping these young people with coping mechanisms and knowledge to support themselves and each other.</p>

        <h6><b>Age-Appropriate SRH Education</b></h6>
        <p>Recognizing the diverse age range of attendees, the SRH session was divided into age-based groups to create a comfortable space for dialogue tailored to each age band. Participants learned about topics like puberty, sexually transmitted infections (STIs), teenage pregnancy, and HIV. The group discussions were led by trained facilitators, including peer educators, psychosocial counselors, and medical professionals, who shared insights and responded to questions. The young participants engaged openly, sharing personal experiences and gaining a better understanding of SRH topics relevant to their lives.</p>

        <h6><b>Substance Abuse Prevention</b></h6>
        <p>The session on substance abuse was led by a professional from Chinama Hospital's substance abuse rehabilitation unit. She spoke to the youth about the dangers of substance misuse and shared information on accessing help. This session empowered the children with knowledge on making safer choices, offering them hope and guidance on how to seek support if needed.</p>

        <h6><b>Partnership and Support</b></h6>
        <p>The event concluded with a shared meal provided by Thrive Aid through the orphanage. Mr. Fidelis Mboma, a representative from the Ministry of Community Development and Social Services, Department of Child Development, was present to show support. Commending Thrive Aid's dedication, he highlighted the importance of partnerships in reaching marginalized youth, especially those living on the streets. The Visionary Student Initiative, another organization invited to facilitate sessions, also contributed, enriching the day's discussions.</p>

        <h6><b>Impact and Commitment</b></h6>
        <p>The event was a meaningful step toward helping street-connected and vulnerable young people in Zambia access the resources, guidance, and support they need to thrive. Through this outreach, Thrive Aid reaffirmed its commitment to fostering resilience, health, and hope among the most vulnerable in our society.</p>

        <p><strong>#MentalHealth #AdolescentHealth #ThriveAid #TransformingLives</strong></p>
        """,
        images: [
          "/images/news/news3/2.jpg",
          "/images/news/news3/3.jpg",
          "/images/news/news3/4.jpg",
          "/images/news/news3/5.jpg"
        ]
      }
    ]

    {:ok, assign(socket, news_articles: news_articles, selected_article: nil, current_page: "news")}
  end

  @impl true
  def handle_event("show-article", %{"id" => id}, socket) do
    id = String.to_integer(id)
    article = Enum.find(socket.assigns.news_articles, &(&1.id == id))
    {:noreply, assign(socket, selected_article: article)}
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, selected_article: nil)}
  end
end
