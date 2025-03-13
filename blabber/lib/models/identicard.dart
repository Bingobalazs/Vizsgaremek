import 'dart:convert';

class Identicard {
  String? name;
  String? profilePicture;
  String? coverPhoto;
  String? bio;
  String? location;
  DateTime? birthday;
  String? pronouns;
  String? relationshipStatus;
  String? phone;
  Map<String, String>? messagingApps;
  String? website;
  Map<String, String>? socialHandles;
  String? currentWorkplace;
  String? jobTitle;
  List<Map<String, String>>? previousWorkplaces;
  List<Map<String, String>>? education;
  List<String>? skills;
  List<Map<String, String>>? certifications;
  List<Map<String, String>>? languages;
  String? portfolioLink;
  List<String>? hobbies;
  String? themePrimaryColor;
  String? themeAccentColor;
  String? themeBgColor;
  String? themeTextColor;
  String? profileVisibility;

  Identicard({
    this.name,
    this.profilePicture,
    this.coverPhoto,
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
    this.portfolioLink,
    this.hobbies,
    this.themePrimaryColor,
    this.themeAccentColor,
    this.themeBgColor,
    this.themeTextColor,
    this.profileVisibility,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profile_picture': profilePicture,
      'cover_photo': coverPhoto,
      'bio': bio,
      'location': location,
      'birthday': birthday?.toIso8601String(),
      'pronouns': pronouns,
      'relationship_status': relationshipStatus,
      'phone': phone,
      'messaging_apps': jsonEncode(messagingApps),
      'website': website,
      'social_handles': jsonEncode(socialHandles),
      'current_workplace': currentWorkplace,
      'job_title': jobTitle,
      'previous_workplaces': jsonEncode(previousWorkplaces),
      'education': jsonEncode(education),
      'skills': skills,
      'certifications': jsonEncode(certifications),
      'languages': jsonEncode(languages),
      'portfolio_link': portfolioLink,
      'hobbies': hobbies,
      'theme_primary_color': themePrimaryColor,
      'theme_accent_color': themeAccentColor,
      'theme_bg_color': themeBgColor,
      'theme_text_color': themeTextColor,
      'profile_visibility': profileVisibility,
    };
  }

  factory Identicard.fromJson(Map<String, dynamic> json) {
    return Identicard(
      name: json['name'],
      profilePicture: json['profile_picture'],
      coverPhoto: json['cover_photo'],
      bio: json['bio'],
      location: json['location'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      pronouns: json['pronouns'],
      relationshipStatus: json['relationship_status'],
      phone: json['phone'],
      messagingApps: json['messaging_apps'] != null
          ? Map<String, String>.from(jsonDecode(json['messaging_apps']))
          : null,
      website: json['website'],
      socialHandles: json['social_handles'] != null
          ? Map<String, String>.from(jsonDecode(json['social_handles']))
          : null,
      currentWorkplace: json['current_workplace'],
      jobTitle: json['job_title'],
      previousWorkplaces: json['previous_workplaces'] != null
          ? List<Map<String, String>>.from(
          jsonDecode(json['previous_workplaces']).map((x) => Map<String, String>.from(x)))
          : null,
      education: json['education'] != null
          ? List<Map<String, String>>.from(
          jsonDecode(json['education']).map((x) => Map<String, String>.from(x)))
          : null,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      certifications: json['certifications'] != null
          ? List<Map<String, String>>.from(
          jsonDecode(json['certifications']).map((x) => Map<String, String>.from(x)))
          : null,
      languages: json['languages'] != null
          ? List<Map<String, String>>.from(
          jsonDecode(json['languages']).map((x) => Map<String, String>.from(x)))
          : null,
      portfolioLink: json['portfolio_link'],
      hobbies: json['hobbies'] != null ? List<String>.from(json['hobbies']) : null,
      themePrimaryColor: json['theme_primary_color'],
      themeAccentColor: json['theme_accent_color'],
      themeBgColor: json['theme_bg_color'],
      themeTextColor: json['theme_text_color'],
      profileVisibility: json['profile_visibility'],
    );
  }
}