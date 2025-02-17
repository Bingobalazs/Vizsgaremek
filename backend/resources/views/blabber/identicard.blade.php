<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>{{ $user->name}}</title>
</head>
<body>

<style>
        :root {
            --primary-color: {{ $user->theme_primary_color ?? '#3490dc' }};
            --accent-color: {{ $user->theme_accent_color ?? '#9561e2' }};
            --bg-color: {{ $user->theme_bg_color ?? '#f8fafc' }};
            --text-color: {{ $user->theme_text_color ?? '#2d3748' }};
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-color);
            font-family: 'Inter', sans-serif;
        }

        .identity-beam-profile {
            max-width: 900px;
            margin: 0 auto;
            padding: 0;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
            background: white;
        }

        .cover-container {
            position: relative;
            height: 280px;
            overflow: hidden;
        }

        .cover-photo {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .profile-header {
            position: relative;
            margin-top: -70px;
            padding: 0 30px;
        }

        .profile-picture-container {
            position: relative;
        }

        .profile-picture {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            border: 4px solid white;
            object-fit: cover;
        }

        .user-info {
            padding: 15px 30px 20px;
        }

        .name-container {
            display: flex;
            align-items: center;
            margin-top: 10px;
        }

        .user-name {
            font-size: 1.8rem;
            font-weight: 700;
            margin-right: 10px;
        }

        .username {
            color: #6b7280;
            font-size: 1.1rem;
        }

        .bio {
            margin: 20px 0;
            font-size: 1rem;
            line-height: 1.6;
        }

        .section {
            border-top: 1px solid #e5e7eb;
            padding: 25px 30px;
        }

        .section-title {
            color: var(--primary-color);
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .detail-item {
            display: flex;
            margin-bottom: 12px;
        }

        .detail-icon {
            color: var(--accent-color);
            width: 24px;
            margin-right: 10px;
        }

        .detail-content {
            flex: 1;
        }

        .detail-label {
            font-weight: 500;
            margin-bottom: 2px;
        }

        .detail-value {
            color: #4b5563;
        }

        .pills-container {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .pill {
            background-color: rgba(var(--primary-color-rgb), 0.1);
            color: var(--primary-color);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
        }

        .social-links {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .social-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #f3f4f6;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            transition: all 0.2s;
        }

        .social-icon:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .identity-beam-footer {
            text-align: center;
            padding: 15px;
            font-size: 0.9rem;
            color: #6b7280;
        }

        .privacy-badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 8px;
            background-color: #f3f4f6;
            border-radius: 4px;
            margin-left: 10px;
            font-size: 0.8rem;
            color: #6b7280;
        }

        .privacy-icon {
            margin-right: 4px;
        }

        @media (max-width: 640px) {
            .profile-header {
                padding: 0 20px;
            }

            .user-info, .section {
                padding: 15px 20px;
            }

            .profile-picture {
                width: 120px;
                height: 120px;
            }
        }
    </style>


    <div style="color: red; font-size: 24px;">Teszt</div>

    <div class="container my-4">
        <div class="identity-beam-profile">
            <!-- Cover Photo -->
            <div class="cover-container">
                @if($user->cover_photo)
                    <img src="{{ asset('storage/' . $user->cover_photo) }}" alt="Cover Photo" class="cover-photo">
                @else
                    <div class="cover-photo" style="background: linear-gradient(135deg, var(--primary-color), var(--accent-color))"></div>
                @endif
            </div>

            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-picture-container">
                    @if($user->profile_picture)
                        <img src="{{ asset('storage/' . $user->profile_picture) }}" alt="{{ $user->name }}" class="profile-picture">
                    @else
                        <div class="profile-picture" style="background: var(--primary-color); display: flex; align-items: center; justify-content: center;">
                            <span style="color: white; font-size: 48px; font-weight: bold;">{{ substr($user->name, 0, 1) }}</span>
                        </div>
                    @endif
                </div>
            </div>

            <!-- User Info -->
            <div class="user-info">
                <div class="name-container">
                    <h1 class="user-name">{{ $user->name }}</h1>
                    <span class="username">@{{ $user->username }}</span>
                    @if($user->profile_visibility == 'public')
                        <span class="privacy-badge"><i class="fas fa-globe privacy-icon"></i> Public</span>
                    @else
                        <span class="privacy-badge"><i class="fas fa-lock privacy-icon"></i> Private</span>
                    @endif
                </div>

                <div class="sub-info">
                    @if($user->pronouns)
                        <span class="pronouns">{{ $user->pronouns }}</span>
                    @endif

                    @if($user->relationship_status)
                        <span class="relationship">• {{ $user->relationship_status }}</span>
                    @endif
                </div>

                @if($user->bio)
                    <p class="bio">{{ $user->bio }}</p>
                @endif

                <div class="location-age">
                    @if($user->location)
                        <span><i class="fas fa-map-marker-alt mr-2" style="color: var(--accent-color);"></i> {{ $user->location }}</span>
                    @endif

                    @if($user->birthday && $user->birthday_visibility != 'hidden')
                        <span class="ml-3">
                        <i class="fas fa-birthday-cake mr-2" style="color: var(--accent-color);"></i>
                        @if($user->birthday_visibility == 'age_only')
                                {{ \Carbon\Carbon::parse($user->birthday)->age }} years old
                            @else
                                {{ \Carbon\Carbon::parse($user->birthday)->format('F j, Y') }}
                            @endif
                    </span>
                    @endif
                </div>
            </div>

            <!-- Contact Information -->
            <div class="section">
                <h2 class="section-title">Contact Information</h2>

                @if($user->email_visibility != 'hidden')
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Email</div>
                            <div class="detail-value">{{ $user->email }}</div>
                            @if($user->email_visibility == 'private')
                                <small class="text-muted"><i class="fas fa-lock"></i> Only visible to connections</small>
                            @endif
                        </div>
                    </div>
                @endif

                @if($user->phone && $user->phone_visibility != 'hidden')
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-phone"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Phone</div>
                            <div class="detail-value">{{ $user->phone }}</div>
                            @if($user->phone_visibility == 'private')
                                <small class="text-muted"><i class="fas fa-lock"></i> Only visible to connections</small>
                            @endif
                        </div>
                    </div>
                @endif

                @if($user->messaging_apps)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-comment-dots"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Messaging Apps</div>
                            @foreach(json_decode($user->messaging_apps) as $app => $username)
                                <div class="detail-value">{{ ucfirst($app) }}: {{ $username }}</div>
                            @endforeach
                        </div>
                    </div>
                @endif

                @if($user->website)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-globe"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Website</div>
                            <div class="detail-value">
                                <a href="{{ $user->website }}" target="_blank" class="text-blue-500 hover:underline">{{ $user->website }}</a>
                            </div>
                        </div>
                    </div>
                @endif

                @if($user->social_handles && count(json_decode($user->social_handles, true)) > 0)
                    <div class="social-links">
                        @foreach(json_decode($user->social_handles, true) as $platform => $handle)
                            <a href="{{ $handle }}" target="_blank" class="social-icon">
                                <i class="fab fa-{{ strtolower($platform) }}"></i>
                            </a>
                        @endforeach
                    </div>
                @endif
            </div>

            <!-- Professional Information -->
            <div class="section">
                <h2 class="section-title">Professional Information</h2>

                @if($user->current_workplace)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-building"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Current Workplace</div>
                            <div class="detail-value">{{ $user->current_workplace }}</div>
                            @if($user->job_title)
                                <div class="detail-value text-gray-500">{{ $user->job_title }}</div>
                            @endif
                        </div>
                    </div>
                @endif

                @if($user->previous_workplaces && count(json_decode($user->previous_workplaces, true)) > 0)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-history"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Previous Experience</div>
                            @foreach(json_decode($user->previous_workplaces, true) as $workplace)
                                <div class="detail-value">{{ $workplace['position'] }} at {{ $workplace['company'] }}</div>
                                <div class="detail-value text-gray-500 text-sm">{{ $workplace['duration'] }}</div>
                            @endforeach
                        </div>
                    </div>
                @endif

                @if($user->education && count(json_decode($user->education, true)) > 0)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-graduation-cap"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Education</div>
                            @foreach(json_decode($user->education, true) as $edu)
                                <div class="detail-value">{{ $edu['degree'] }} - {{ $edu['institution'] }}</div>
                                <div class="detail-value text-gray-500 text-sm">{{ $edu['year'] }}</div>
                            @endforeach
                        </div>
                    </div>
                @endif

                @if($user->skills && count(json_decode($user->skills, true)) > 0)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-tools"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Skills & Expertise</div>
                            <div class="pills-container">
                                @foreach(json_decode($user->skills, true) as $skill)
                                    <span class="pill">{{ $skill }}</span>
                                @endforeach
                            </div>
                        </div>
                    </div>
                @endif

                @if($user->certifications && count(json_decode($user->certifications, true)) > 0)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-certificate"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Certifications</div>
                            @foreach(json_decode($user->certifications, true) as $cert)
                                <div class="detail-value">{{ $cert['name'] }}</div>
                                <div class="detail-value text-gray-500 text-sm">{{ $cert['issuer'] }} - {{ $cert['year'] }}</div>
                            @endforeach
                        </div>
                    </div>
                @endif

                @if($user->languages && count(json_decode($user->languages, true)) > 0)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-language"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Languages</div>
                            <div class="pills-container">
                                @foreach(json_decode($user->languages, true) as $language => $proficiency)
                                    <span class="pill">{{ $language }} ({{ $proficiency }})</span>
                                @endforeach
                            </div>
                        </div>
                    </div>
                @endif

                @if($user->portfolio_link)
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-briefcase"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Portfolio</div>
                            <div class="detail-value">
                                <a href="{{ $user->portfolio_link }}" target="_blank" class="text-blue-500 hover:underline">View Portfolio</a>
                            </div>
                        </div>
                    </div>
                @endif
            </div>

            <!-- Personal Interests -->
            @if($user->hobbies && count(json_decode($user->hobbies, true)) > 0)
                <div class="section">
                    <h2 class="section-title">Personal Interests</h2>
                    <div class="detail-item">
                        <div class="detail-icon">
                            <i class="fas fa-heart"></i>
                        </div>
                        <div class="detail-content">
                            <div class="detail-label">Hobbies</div>
                            <div class="pills-container">
                                @foreach(json_decode($user->hobbies, true) as $hobby)
                                    <span class="pill">{{ $hobby }}</span>
                                @endforeach
                            </div>
                        </div>
                    </div>
                </div>
            @endif

            <!-- Footer -->
            <div class="identity-beam-footer">
                Shared via IdentityBeam |
                <a href="{{ route('connect', $user->username) }}" class="text-primary hover:underline">
                    Connect with {{ $user->name }}
                </a>
            </div>
        </div>
    </div>


    <script>
        // Convert primary color hex to RGB for use in computed values

        /*document.addEventListener('DOMContentLoaded', function() {
            const primaryColor = getComputedStyle(document.documentElement).getPropertyValue('--primary-color').trim();
            const rgb = hexToRgb(primaryColor);
            if (rgb) {
                document.documentElement.style.setProperty('--primary-color-rgb', `${rgb.r}, ${rgb.g}, ${rgb.b}`);
            }
        });*/

        function hexToRgb(hex) {
            // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
            const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
            hex = hex.replace(shorthandRegex, function(m, r, g, b) {
                return r + r + g + g + b + b;
            });

            const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            return result ? {
                r: parseInt(result[1], 16),
                g: parseInt(result[2], 16),
                b: parseInt(result[3], 16)
            } : null;
        }
    </script>

</body>
</html>
