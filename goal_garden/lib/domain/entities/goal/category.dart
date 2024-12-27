import 'package:flutter/material.dart';

enum Category {
  personalGrowth,
  careerEducation,
  healthFitness,
  relationshipsCommunity,
  finance,
  lifestyleAdventure,
  spiritualityReligion,
  homeEnvironnement,
  other
}

extension CategoryExtension on Category {
  String get title {
    switch (this) {
      case Category.personalGrowth:
        return "Personal Growth";
      case Category.careerEducation:
        return "Career & Education";
      case Category.healthFitness:
        return "Health & Fitness";
      case Category.relationshipsCommunity:
        return "Relationships & Community";
      case Category.finance:
        return "Finance";
      case Category.lifestyleAdventure:
        return "Lifestyle & Adventure";
      case Category.spiritualityReligion:
        return "Spirituality & Religion";
      case Category.homeEnvironnement:
        return "Home & Environnement";
      case Category.other:
        return "Other";
    }
  }

  IconData get icon {
    switch (this) {
      case Category.personalGrowth:
        return Icons.self_improvement;
      case Category.careerEducation:
        return Icons.work;
      case Category.healthFitness:
        return Icons.fitness_center;
      case Category.relationshipsCommunity:
        return Icons.group;
      case Category.finance:
        return Icons.attach_money;
      case Category.lifestyleAdventure:
        return Icons.travel_explore;
      case Category.spiritualityReligion:
        return Icons.volunteer_activism;
      case Category.homeEnvironnement:
        return Icons.home;
      case Category.other:
        return Icons.category;
    }
  }
}
