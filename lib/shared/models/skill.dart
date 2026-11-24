import 'package:flutter/widgets.dart';

@immutable
class Skill {
  const Skill(this.name, this.icon, this.description);

  final String name;
  final IconData icon;
  final String description;
}

@immutable
class SkillCategory {
  const SkillCategory(this.name, this.icon, this.skills);

  final String name;
  final IconData icon;
  final List<Skill> skills;
}
