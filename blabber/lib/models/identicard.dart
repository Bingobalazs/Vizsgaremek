import 'dart:convert';

// Main Identicard model
class Identicard {
  int? userId;
  int? id;
  String? name;
  String? username;
  String? createdAt;
  String? updatedAt;
  String? bio;
  String? location;
  String? birthday;
  String? pronouns;
  String? relationshipStatus;
  String? phone;
  String? messagingApps;
  String? website;
  String? socialHandles;
  String? currentWorkplace;
  String? jobTitle;
  String? previousWorkplaces;
  String? education;
  List<String>? skills; // Updated
  String? certifications;
  String? languages;
  List<String>? hobbies; // Updated
  String? portfolioLink;
  String? themePrimaryColor;
  String? themeAccentColor;
  String? themeBgColor;
  String? themeTextColor;
  String? profileVisibility;

  Identicard({
    this.userId,
    this.id,
    this.name,
    this.username,
    this.createdAt,
    this.updatedAt,
    this.bio,
    this.location,
    this.birthday,
    this.pronouns,
    this.relationshipStatus,
    this.phone,
    this.messagingApps,
    this.website,
    this.socialHandles,
    this.currentWorkplace,
    this.jobTitle,
    this.previousWorkplaces,
    this.education,
    this.skills,
    this.certifications,
    this.languages,
    this.hobbies,
    this.portfolioLink,
    this.themePrimaryColor,
    this.themeAccentColor,
    this.themeBgColor,
    this.themeTextColor,
    this.profileVisibility,
  });

  factory Identicard.fromJson(Map<String, dynamic> json) {
    return Identicard(
      userId: json['user_id'],
      id: json['id'],
      name: json['name'],
      username: json['username'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      bio: json['bio'],
      location: json['location'],
      birthday: json['birthday'],
      pronouns: json['pronouns'],
      relationshipStatus: json['relationship_status'],
      phone: json['phone'],
      messagingApps: json['messaging_apps'],
      website: json['website'],
      socialHandles: json['social_handles'],
      currentWorkplace: json['current_workplace'],
      jobTitle: json['job_title'],
      previousWorkplaces: json['previous_workplaces'],
      education: json['education'],
      skills: json['skills'] != null ? List<String>.from(jsonDecode(json['skills'])) : null,
      certifications: json['certifications'],
      languages: json['languages'],
      hobbies: json['hobbies'] != null ? List<String>.from(jsonDecode(json['hobbies'])) : null,
      portfolioLink: json['portfolio_link'],
      themePrimaryColor: json['theme_primary_color'],
      themeAccentColor: json['theme_accent_color'],
      themeBgColor: json['theme_bg_color'],
      themeTextColor: json['theme_text_color'],
      profileVisibility: json['profile_visibility'],
    );
  }
}

// Sub-model for previous_workplaces
class Workplace {
  String company;
  String position;
  String duration;

  Workplace({required this.company, required this.position, required this.duration});

  Map<String, dynamic> toJson() => {
    'company': company,
    'position': position,
    'duration': duration,
  };

  factory Workplace.fromJson(Map<String, dynamic> json) => Workplace(
    company: json['company'],
    position: json['position'],
    duration: json['duration'],
  );
}

// Sub-model for education
class Education {
  String institution;
  String degree;
  String year;

  Education({required this.institution, required this.degree, required this.year});

  Map<String, dynamic> toJson() => {
    'institution': institution,
    'degree': degree,
    'year': year,
  };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    institution: json['institution'],
    degree: json['degree'],
    year: json['year'],
  );
}

// Sub-model for certifications
class Certification {
  String name;
  String issuer;
  String year;

  Certification({required this.name, required this.issuer, required this.year});

  Map<String, dynamic> toJson() => {
    'name': name,
    'issuer': issuer,
    'year': year,
  };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
    name: json['name'],
    issuer: json['issuer'],
    year: json['year'],
  );
}