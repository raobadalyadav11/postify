import 'package:flutter/material.dart';
import '../models/template_model.dart';

class SampleData {
  static List<TemplateModel> generateSampleTemplates() {
    final templates = <TemplateModel>[];
    final now = DateTime.now();
    
    // Political Templates
    final politicalTemplates = [
      {
        'name': 'Candidate Introduction',
        'type': 'Candidate Introduction',
        'description': 'Professional candidate introduction template',
      },
      {
        'name': 'Voting Appeal',
        'type': 'Voting Appeal',
        'description': 'Encourage voters to participate',
      },
      {
        'name': 'Victory Celebration',
        'type': 'Victory Celebration',
        'description': 'Celebrate election victory',
      },
      {
        'name': 'Rally Invitation',
        'type': 'Rally & Event',
        'description': 'Invite people to political rallies',
      },
    ];
    
    for (int i = 0; i < politicalTemplates.length; i++) {
      final template = politicalTemplates[i];
      templates.add(TemplateModel(
        templateId: 'political_$i',
        category: 'Political',
        type: template['type']!,
        name: template['name']!,
        imagePath: 'assets/templates/political_${i + 1}.png',
        metadata: {
          'description': template['description'],
          'textFields': ['title', 'subtitle', 'description'],
          'imageFields': ['candidatePhoto', 'partyLogo'],
          'colors': ['primary', 'secondary', 'accent'],
        },
        language: 'en',
        width: 1080,
        height: 1920,
        createdAt: now,
      ));
    }
    
    // Festival Templates
    final festivalTemplates = [
      {
        'name': 'Diwali Greetings',
        'type': 'Diwali',
        'description': 'Beautiful Diwali celebration template',
      },
      {
        'name': 'Holi Celebration',
        'type': 'Holi',
        'description': 'Colorful Holi festival template',
      },
      {
        'name': 'Eid Mubarak',
        'type': 'Eid',
        'description': 'Elegant Eid celebration template',
      },
      {
        'name': 'Christmas Joy',
        'type': 'Christmas',
        'description': 'Festive Christmas greeting template',
      },
    ];
    
    for (int i = 0; i < festivalTemplates.length; i++) {
      final template = festivalTemplates[i];
      templates.add(TemplateModel(
        templateId: 'festival_$i',
        category: 'Festival',
        type: template['type']!,
        name: template['name']!,
        imagePath: 'assets/templates/festival_${i + 1}.png',
        metadata: {
          'description': template['description'],
          'textFields': ['greeting', 'message', 'signature'],
          'imageFields': ['festivalImage', 'userPhoto'],
          'colors': ['festivalColor', 'textColor'],
        },
        language: 'en',
        width: 1080,
        height: 1080,
        createdAt: now,
      ));
    }
    
    // Social Media Templates
    final socialTemplates = [
      {
        'name': 'Instagram Post',
        'type': 'Social Media Square',
        'description': 'Perfect for Instagram posts',
      },
      {
        'name': 'Facebook Cover',
        'type': 'Social Media Square',
        'description': 'Facebook cover photo template',
      },
    ];
    
    for (int i = 0; i < socialTemplates.length; i++) {
      final template = socialTemplates[i];
      templates.add(TemplateModel(
        templateId: 'social_$i',
        category: 'Social Media',
        type: template['type']!,
        name: template['name']!,
        imagePath: 'assets/templates/social_${i + 1}.png',
        metadata: {
          'description': template['description'],
          'textFields': ['title', 'description'],
          'imageFields': ['backgroundImage'],
          'colors': ['primary', 'text'],
        },
        language: 'en',
        width: i == 0 ? 1080 : 1200,
        height: i == 0 ? 1080 : 628,
        createdAt: now,
      ));
    }
    
    return templates;
  }
  
  static Map<String, String> getSampleTexts() {
    return {
      'political_greeting': 'Vote for Progress, Vote for Change',
      'political_slogan': 'Together We Build Tomorrow',
      'festival_greeting': 'Wishing you joy and prosperity',
      'festival_message': 'May this festival bring happiness to your family',
      'general_title': 'Your Title Here',
      'general_subtitle': 'Your subtitle or message',
    };
  }
  
  static List<Color> getSampleColors() {
    return [
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF795548), // Brown
    ];
  }
}