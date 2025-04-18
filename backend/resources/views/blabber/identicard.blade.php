
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $user->name }} | Profile</title>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: {{ $user->theme_primary_color ?? '#0ff' }};
            --accent: {{ $user->theme_accent_color ?? '#f0f' }};
            --background: {{ $user->theme_bg_color ?? '#121212' }};
            --text: {{ $user->theme_text_color ?? '#fff' }};
            --glow: 0 0 5px var(--primary), 0 0 10px var(--primary);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background-color: var(--background);
            color: var(--text);
            font-family: 'Rajdhani', sans-serif;
            line-height: 1.6;
            overflow-x: hidden;
        }

        .glitch-container {
            position: relative;
        }

        .glitch {
            position: relative;
            font-size: 3.5rem;
            font-weight: 700;
            text-transform: uppercase;
            text-shadow: 0.05em 0 0 rgba(255, 0, 255, 0.75),
            -0.025em -0.05em 0 rgba(0, 255, 255, 0.75),
            0.025em 0.05em 0 rgba(255, 255, 0, 0.75);
            animation: glitch 500ms infinite;
        }



        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .profile-header {
            position: relative;
            height: 300px;
            margin-bottom: 100px;
            overflow: hidden;
            border-radius: 15px;
            border: 1px solid var(--primary);
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.5);
        }

        .cover-photo {
            width: 100%;
            height: 100%;
            object-fit: cover;
            filter: brightness(0.7) contrast(1.2) saturate(1.2);
        }

        .profile-picture-container {
            position: absolute;
            bottom: -20px;
            left: 50px;
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 5px solid var(--background);
            overflow: hidden;
            box-shadow: var(--glow);
        }

        .profile-picture {
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: 100;
        }

        .profile-id {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.7);
            padding: 5px 10px;
            border-radius: 5px;
            font-family: 'Share Tech Mono', monospace;
            border: 1px solid var(--accent);
            color: var(--accent);
        }

        .profile-details {
            display: grid;
            grid-template-columns: 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        @media (min-width: 768px) {
            .profile-details {
                grid-template-columns: 1fr 1fr;
            }
        }

        .card {
            background: rgba(18, 18, 18, 0.8);
            border-radius: 10px;
            padding: 25px;
            position: relative;
            backdrop-filter: blur(5px);
            border: 1px solid var(--primary);
            overflow: hidden;
        }

       /* .card::before {
            content: '';
            position: absolute;
            top: -5px;
            left: -5px;
            right: -5px;
            bottom: -5px;
            z-index: -1;
            background: linear-gradient(45deg, var(--primary), var(--accent), var(--primary));
            background-size: 200%;
            animation: border-animation 3s linear infinite;
            filter: blur(8px);
            opacity: 0.7;
        }*/



        .section-title {
            font-size: 1.8rem;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: var(--primary);
        }

        .section-title .material-icons {
            margin-right: 10px;
        }

        .info-group {
            margin-bottom: 15px;
        }

        .info-label {
            font-size: 0.9rem;
            color: var(--accent);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
            font-family: 'Share Tech Mono', monospace;
        }

        .info-value {
            font-size: 1.1rem;
            word-break: break-word;
        }

        .social-links {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 15px;
        }

        .social-link {
            display: flex;
            align-items: center;
            gap: 5px;
            text-decoration: none;
            color: var(--text);
            padding: 5px 10px;
            border-radius: 5px;
            background: rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            border: 1px solid var(--primary);
        }

        .social-link:hover {
            background: rgba(0, 255, 255, 0.2);
            transform: translateY(-3px);
            box-shadow: var(--glow);
        }

        .skill-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .skill-tag {
            background: var(--background);
            color: var(--text);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
            border: 1px solid var(--primary);
        }

        .timeline-item {
            position: relative;
            padding-left: 30px;
            margin-bottom: 20px;
        }

        .timeline-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(to bottom, var(--primary), var(--accent));
        }

        .timeline-item::after {
            content: '';
            position: absolute;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: var(--accent);
            left: -5px;
            top: 10px;
            border: 2px solid var(--background);
        }

        .timeline-title {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .timeline-subtitle {
            font-size: 0.9rem;
            color: var(--accent);
            margin-bottom: 5px;
        }

        .timeline-date {
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.6);
            font-family: 'Share Tech Mono', monospace;
        }

        .animated-background {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -2;
            opacity: 0.1;
            background:
                linear-gradient(125deg,
                var(--background) 0%,
                var(--background) 40%,
                var(--primary) 50%,
                var(--background) 60%,
                var(--background) 100%);
            background-size: 400% 400%;
            animation: gradientBg 15s ease infinite;
        }



        .grid-line {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: linear-gradient(var(--primary) 1px, transparent 1px),
            linear-gradient(90deg, var(--primary) 1px, transparent 1px);
            background-size: 50px 50px;
            z-index: -1;
            opacity: 0.05;
        }

        footer {
            text-align: center;
            padding: 30px 0;
            margin-top: 50px;
            font-family: 'Share Tech Mono', monospace;
            color: var(--accent);
            font-size: 0.9rem;
        }

        .private-info {
            font-style: italic;
            opacity: 0.7;
        }
    </style>
</head>
<body>
<div class="animated-background"></div>

<div class="container">



{{--
        <div class="profile-picture-container">
            @if($user->profile_picture)
                <img src="{{ $user->profile_picture }}" alt="{{ $user->name }}" class="profile-picture">
            @else
                <div class="profile-picture" style="background: linear-gradient(135deg, var(--primary), var(--accent))"></div>
            @endif
        </div>

--}}


    <div class="glitch-container">
        <h1 style="color: var(--accent)">{{ $user->name }}</h1>
    </div>

    <p style="margin-bottom: 40px; font-size: 1.2rem; color: var(--accent); font-family: 'Share Tech Mono', monospace;">
        @if($user->pronouns){{ $user->pronouns }} • @endif
        @if($user->location){{ $user->location }} • @endif
        @if($user->job_title && $user->current_workplace){{ $user->job_title }} at {{ $user->current_workplace }}@endif
    </p>

    <div class="profile-details">
        <!-- Bio and Personal Info -->
        <div class="card">
            <h2 class="section-title">
                <span class="material-icons">person</span>
                Personal Info
            </h2>

            @if($user->bio)
                <div class="info-group">
                    <p>{{ $user->bio }}</p>
                </div>
            @endif

            @if($user->username)
                <div class="info-group">
                    <div class="info-label">Username</div>
                    <div class="info-value">{{ $user->username }}</div>
                </div>
            @endif

            @if($user->birthday)
                <div class="info-group">
                    <div class="info-label">Birthday</div>
                    <div class="info-value">{{ \Carbon\Carbon::parse($user->birthday)->format('Y, M d') }}</div>
                </div>
            @endif

            @if($user->relationship_status)
                <div class="info-group">
                    <div class="info-label">Relationship Status</div>
                    <div class="info-value">{{ $user->relationship_status }}</div>
                </div>
            @endif

            @if($user->hobbies)
                @php
                    $hobbies = json_decode($user->hobbies, true);
                @endphp
                <div class="info-group">
                    <div class="info-label">Interests</div>
                    <div class="skill-tags">
                        @if(is_array($hobbies))
                            @foreach($hobbies as $hobby)
                                <span class="skill-tag">{{ $hobby }}</span>
                            @endforeach
                        @else
                            <span class="skill-tag">{{ $user->hobbies }}</span>
                        @endif
                    </div>
                </div>
            @endif



        </div>

        <!-- Contact Info -->
        <div class="card">
            <h2 class="section-title">
                <span class="material-icons">contact_page</span>
                Contact Info
            </h2>

            @if($user->email)
                <div class="info-group">
                    <div class="info-label">Email</div>
                    <div class="info-value">
                        <a href="mailto:{{ $user->email }}" style="color: var(--primary); text-decoration: none;">
                            {{ $user->email }}
                        </a>
                    </div>
                </div>
            @endif

            @if($user->phone )
                <div class="info-group">
                    <div class="info-label">Phone</div>
                    <div class="info-value">
                        <a href="tel:{{ $user->phone }}" style="color: var(--primary); text-decoration: none;">
                            {{ $user->phone }}
                        </a>
                    </div>
                </div>
            @endif

            @if($user->website)
                <div class="info-group">
                    <div class="info-label">Website</div>
                    <div class="info-value">
                        <a href="{{ $user->website }}" target="_blank" style="color: var(--primary); text-decoration: none;">
                            {{ $user->website }}
                        </a>
                    </div>
                </div>
            @endif

            @if($user->messaging_apps)
                <div class="info-group">
                    <div class="info-label">Messaging</div>
                    <div class="info-value">
                        @php
                            $apps = json_decode($user->messaging_apps, true);
                        @endphp
                        @if(is_array($apps))
                            @foreach($apps as $app => $handle)
                                <div>{{ $app }}: {{ $handle }}</div>
                            @endforeach
                        @else
                            {{ $user->messaging_apps }}
                        @endif
                    </div>
                </div>
            @endif

            @if($user->social_handles)
                <div class="info-group">
                    <div class="info-label">Social Media</div>
                    <div class="social-links">
                        @php
                            $socials = json_decode($user->social_handles, true);
                        @endphp
                        @if(is_array($socials))
                            @foreach($socials as $platform => $handle)
                                <a href="#" class="social-link">
                                    <span class="material-icons">
                                        @switch(strtolower($platform))
                                            @case('twitter')
                                                tag
                                                @break
                                            @case('instagram')
                                                photo_camera
                                                @break
                                            @case('linkedin')
                                                business
                                                @break
                                            @case('github')
                                                code
                                                @break
                                            @case('facebook')
                                                thumb_up
                                                @break
                                            @default
                                                link
                                        @endswitch
                                    </span>
                                    {{ $handle }}
                                </a>
                            @endforeach
                        @else
                            {{ $user->social_handles }}
                        @endif
                    </div>
                </div>
            @endif
        </div>

        <!-- Work Experience -->
        <div class="card">
            <h2 class="section-title">
                <span class="material-icons">work</span>
                Work Experience
            </h2>

            @if($user->current_workplace)
                <div class="timeline-item">
                    <div class="timeline-title">{{ $user->current_workplace }}</div>
                    @if($user->job_title)
                        <div class="timeline-subtitle">{{ $user->job_title }}</div>
                    @endif
                    <div class="timeline-date">Present</div>
                </div>
            @endif

            @if($user->previous_workplaces)
                @php
                    $prevWorkplaces = json_decode($user->previous_workplaces, true);
                @endphp

                @if(is_array($prevWorkplaces))
                    @foreach($prevWorkplaces as $job)
                        <div class="timeline-item">
                            <div class="timeline-title">{{ $job['company'] ?? '' }}</div>
                            <div class="timeline-subtitle">{{ $job['title'] ?? '' }}</div>
                            <div class="timeline-date">{{ $job['period'] ?? '' }}</div>
                        </div>
                    @endforeach
                @else
                    <div class="timeline-item">
                        <div class="timeline-title">{{ $user->previous_workplaces }}</div>
                    </div>
                @endif
            @endif
        </div>

        <!-- Education and Skills -->
        <div class="card">
            <h2 class="section-title">
                <span class="material-icons">school</span>
                Education & Skills
            </h2>

            <!-- Education -->
            @if($user->education)
                @php
                    $education = json_decode($user->education, true);
                @endphp

                @if(is_array($education))
                    @foreach($education as $edu)
                        <div class="timeline-item">
                            <div class="timeline-title">{{ $edu['institution'] ?? '' }}</div>
                            <div class="timeline-subtitle">{{ $edu['degree'] ?? '' }}</div>
                            <div class="timeline-date">{{ $edu['year'] ?? '' }}</div>
                        </div>
                    @endforeach
                @else
                    <div class="timeline-item">
                        <div class="timeline-title">{{ $user->education }}</div>
                    </div>
                @endif
            @endif

            <!-- Skills -->
            @if($user->skills)
                @php
                    $skills = json_decode($user->skills, true);
                @endphp
                <div class="info-group">
                    <div class="info-label">Skills</div>
                    <div class="skill-tags">
                        @if(is_array($skills))
                            @foreach($skills as $skill)
                                <span class="skill-tag">{{ $skill }}</span>
                            @endforeach
                        @else
                            <span class="skill-tag">{{ $user->skills }}</span>
                        @endif
                    </div>
                </div>
            @endif

            <!-- Certifications -->
            @if($user->certifications)
                @php
                    $certifications = json_decode($user->certifications, true);
                @endphp
                <div class="info-group">
                    <div class="info-label">Certifications</div>
                    <div class="info-value">
                        @if(is_array($certifications))
                            @foreach($certifications as $cert)
                                <div class="timeline-subtitle">
                                    {{ $cert['name'] ?? '' }} - {{ $cert['issuer'] ?? '' }} ({{ $cert['year'] ?? '' }})
                                </div>
                            @endforeach
                        @else
                            <div class="timeline-subtitle">{{ $user->certifications }}</div>
                        @endif
                    </div>
                </div>
            @endif

            <!-- Languages -->
            @if($user->languages)
                @php
                    $languages = json_decode($user->languages, true);
                @endphp
                <div class="info-group">
                    <div class="info-label">Languages</div>
                    <div class="skill-tags">
                        @if(is_array($languages))
                            @foreach($languages as $lang => $level)
                                <span class="skill-tag">{{ $lang }} ({{ $level }})</span>
                            @endforeach
                        @else
                            <span class="skill-tag">{{ $user->languages }}</span>
                        @endif
                    </div>
                </div>
            @endif
        </div>

        @if($user->portfolio_link)
            <!-- Portfolio -->
            <div class="card">
                <h2 class="section-title">
                    <span class="material-icons">collections</span>
                    Portfolio
                </h2>
                <div class="info-group">
                    <div class="info-value">
                        <a href="{{ $user->portfolio_link }}" target="_blank" class="social-link" style="display: inline-block;">
                            <span class="material-icons">visibility</span>
                            View Portfolio
                        </a>
                    </div>
                </div>
            </div>
        @endif
    </div>
</div>

<footer>
    <p>Last updated: {{ $user->updated_at->diffForHumans() }}</p>
    <p style="margin-top: 10px;">
        <span class="material-icons" style="font-size: 1rem; vertical-align: middle;">copyright</span>
        {{ \Carbon\Carbon::now()->year }} {{ $user->name }}
    </p>
</footer>
</body>
</html>
