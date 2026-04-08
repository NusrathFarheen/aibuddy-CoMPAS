import 'package:flutter/material.dart';

enum WorkspaceSectionType {
  chat, // Standard Chat
  tasks, // Checklist
  draft, // Text Editor (Research/Writing)
  notes, // Simple Notes
  references, // List of links/citations
  code, // Code Snippets
  workout, // Workout Logger
  diet, // Diet Tracker
  photos, // Image Gallery
  journal, // Daily Reflection
  mood, // Mood Tracker
  habit, // Habit/Streak View
  routine, // AM/PM Routine Builder
  kanban, // Project Stages (To Learn, Learning, Practicing, Mastered)
  pipeline, // Workflow Stages (Idea, Research, Draft, Review, Final)
  agile, // Agile Board (Backlog, In Progress, Testing, Completed)
  metrics, // Metric Tracking (Daily Logs, Weekly Progress)
  funnel, // Funnel System (Preparing, Applied, Interviewing, Offers)
  dashboard, // Analytics Dashboard (Income, Expenses, Savings)
  roadmap, // Product Roadmap (Idea, Validation, Build, Launch, Growth)
  freeflow, // Creative Flow (Ideas, Drafts, Inspiration, Publishing)
  author, // Author/Bio Section
  finalization, // Final Submission/Publishing Section
}

enum InteractionStyle {
  kanban,
  pipeline,
  agile,
  tracker,
  routine,
  reflection,
  funnel,
  dashboard,
  roadmap,
  freeflow,
  checklist,
}

class WorkspaceTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<WorkspaceSectionType> sections;
  final String aiRole; // System prompt for the Buddy
  final Color themeColor;
  final InteractionStyle interactionStyle;
  final String progressLogic;

  const WorkspaceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.sections,
    required this.aiRole,
    required this.themeColor,
    required this.interactionStyle,
    required this.progressLogic,
  });
}

class TemplateRegistry {
  static const List<WorkspaceTemplate> templates = [
    // 1. Learning / Study
    WorkspaceTemplate(
      id: 'learning',
      name: 'Learning & Study',
      description: 'Master new skills, languages, or subjects.',
      icon: Icons.school,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.kanban,
        WorkspaceSectionType.notes,
        WorkspaceSectionType.tasks,
        WorkspaceSectionType.habit
      ],
      aiRole:
          "You are a Study Buddy. Explain concepts simply, quiz the user, and help them organize their study schedule. Suggest what to move next in the Kanban and detect stuck topics.",
      themeColor: Colors.blueAccent,
      interactionStyle: InteractionStyle.kanban,
      progressLogic: "Progress increases as cards move from 'To Learn' to 'Mastered'.",
    ),

    // 2. Research / Academic
    WorkspaceTemplate(
      id: 'research',
      name: 'Research & Academic',
      description: 'Write papers, thesis, or manage references.',
      icon: Icons.article,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.pipeline,
        WorkspaceSectionType.draft,
        WorkspaceSectionType.references,
        WorkspaceSectionType.author,
        WorkspaceSectionType.finalization,
        WorkspaceSectionType.notes
      ],
      aiRole:
          "You are a Research Assistant. Help structure arguments, suggest citations, proofread drafts, and push the user to the next pipeline stage.",
      themeColor: Colors.orangeAccent,
      interactionStyle: InteractionStyle.pipeline,
      progressLogic: "Linear progress across stages (Idea -> Research -> Draft -> Review -> Final).",
    ),

    // 3. Project / Build
    WorkspaceTemplate(
      id: 'project',
      name: 'Project & Build',
      description: 'Manage coding projects, startups, or builds.',
      icon: Icons.code,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.agile,
        WorkspaceSectionType.code,
        WorkspaceSectionType.tasks
      ],
      aiRole:
          "You are a Technical Co-founder. Help break down features into tasks, suggest architecture, debug issues, and track velocity.",
      themeColor: Colors.cyanAccent,
      interactionStyle: InteractionStyle.agile,
      progressLogic: "Iterative progress based on sprint cycles and task completion in 'Completed' column.",
    ),

    // 4. Fitness / Health
    WorkspaceTemplate(
      id: 'fitness',
      name: 'Fitness & Health',
      description: 'Track workouts, diet, and body progress.',
      icon: Icons.fitness_center,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.metrics,
        WorkspaceSectionType.workout,
        WorkspaceSectionType.diet,
        WorkspaceSectionType.photos,
        WorkspaceSectionType.habit
      ],
      aiRole:
          "You are a Fitness Coach. Design workout plans, track macronutrients, motivate consistency, and detect burnout or drops in streak.",
      themeColor: Colors.greenAccent,
      interactionStyle: InteractionStyle.tracker,
      progressLogic: "Consistency-based progress: Daily logs, weekly metrics, and streak flames.",
    ),

    // 5. Self-Care / Skincare
    WorkspaceTemplate(
      id: 'skincare',
      name: 'Self-Care & Glow Up',
      description: 'Routines for skincare, haircare, and wellness.',
      icon: Icons.spa,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.routine,
        WorkspaceSectionType.journal,
        WorkspaceSectionType.habit
      ],
      aiRole:
          "You are a Wellness Guide. Help establish AM/PM routines, provide reminders, and tracks product results with before/after notes.",
      themeColor: Colors.pinkAccent,
      interactionStyle: InteractionStyle.routine,
      progressLogic: "Completion-based progress: Morning & Night routine checkboxes + weekly reviews.",
    ),

    // 6. Mental Well-being
    WorkspaceTemplate(
      id: 'mental',
      name: 'Mental Well-being',
      description: 'Journaling, mood tracking, and reflection.',
      icon: Icons.self_improvement,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.journal,
        WorkspaceSectionType.mood,
        WorkspaceSectionType.notes
      ],
      aiRole:
          "You are an Empathetic Listener. Provide a safe space for reflection, mood tracking, and identifying triggers. Reflect, do not instruct.",
      themeColor: Colors.purpleAccent,
      interactionStyle: InteractionStyle.reflection,
      progressLogic: "Reflection-based progress: Timeline of mood input and gratitude journal entries.",
    ),

    // 7. Daily Life / Habits
    WorkspaceTemplate(
      id: 'daily',
      name: 'Daily Life & Habits',
      description: 'Reset your lifestyle and build discipline.',
      icon: Icons.wb_sunny,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.habit,
        WorkspaceSectionType.routine,
        WorkspaceSectionType.tasks
      ],
      aiRole:
          "You are a Life Coach. Suggest habit stacking, celebrate streaks, and nudge the user through daily completion checkboxes.",
      themeColor: Colors.amberAccent,
      interactionStyle: InteractionStyle.checklist,
      progressLogic: "Daily habit completion percentage + streak building.",
    ),

    // 8. Career / Internship
    WorkspaceTemplate(
      id: 'career',
      name: 'Career & Internship',
      description: 'Apply for jobs and track your career growth.',
      icon: Icons.work,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.funnel,
        WorkspaceSectionType.notes,
        WorkspaceSectionType.tasks
      ],
      aiRole:
          "You are a Career Mentor. Help refine resumes, prepare for interviews, and track applications through the funnel.",
      themeColor: Colors.indigoAccent,
      interactionStyle: InteractionStyle.funnel,
      progressLogic: "Funnel conversion progress: Preparing -> Applied -> Interviewing -> Offers.",
    ),

    // 9. Finance / Money
    WorkspaceTemplate(
      id: 'finance',
      name: 'Finance & Money',
      description: 'Manage income, expenses, and savings goals.',
      icon: Icons.payments,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.dashboard,
        WorkspaceSectionType.notes,
        WorkspaceSectionType.tasks
      ],
      aiRole:
          "You are a Financial Advisor. Help set budget goals, track spending habits, and suggest saving strategies.",
      themeColor: Colors.tealAccent,
      interactionStyle: InteractionStyle.dashboard,
      progressLogic: "Metric-based progress: Savings vs Expenses analytics dashboard.",
    ),

    // 10. Startup / Business
    WorkspaceTemplate(
      id: 'startup',
      name: 'Startup & Business',
      description: 'Build your product and launch your startup.',
      icon: Icons.rocket_launch,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.roadmap,
        WorkspaceSectionType.agile,
        WorkspaceSectionType.notes
      ],
      aiRole:
          "You are a Business Strategist. Help validate ideas, plan market research, and track the product roadmap from Idea to Growth.",
      themeColor: Colors.deepOrangeAccent,
      interactionStyle: InteractionStyle.roadmap,
      progressLogic: "Roadmap milestone completion: Idea -> Validation -> Build -> Launch -> Growth.",
    ),

    // 11. Creative / Passion
    WorkspaceTemplate(
      id: 'creative',
      name: 'Creative & Passion',
      description: 'Writing, art, or content creation projects.',
      icon: Icons.palette,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.freeflow,
        WorkspaceSectionType.draft,
        WorkspaceSectionType.notes
      ],
      aiRole:
          "You are a Creative Muse. Help brainstorm ideas, organize drafts, and provide inspiration for publishing work.",
      themeColor: Colors.lightGreenAccent,
      interactionStyle: InteractionStyle.freeflow,
      progressLogic: "Output-based progress: Moving from Idea -> Draft -> Publish.",
    ),

    // 12. Travel / Life Experience
    WorkspaceTemplate(
      id: 'travel',
      name: 'Travel & Experience',
      description: 'Plan trips and document life experiences.',
      icon: Icons.flight_takeoff,
      sections: [
        WorkspaceSectionType.chat,
        WorkspaceSectionType.pipeline,
        WorkspaceSectionType.notes,
        WorkspaceSectionType.photos
      ],
      aiRole:
          "You are a Travel Guide. Help plan itineraries, manage budgets, and document memories and reflections.",
      themeColor: Colors.redAccent,
      interactionStyle: InteractionStyle.pipeline,
      progressLogic: "Stage-based progress: Trip Plan -> Budget -> Itinerary -> Memories -> Reflections.",
    ),
  ];

  static WorkspaceTemplate getTemplate(String id) {
    return templates.firstWhere(
      (t) => t.id == id,
      orElse: () =>
          templates.first, // Default to Learning or a General template
    );
  }

  // Helper to guess template from goal title (MVP Only)
  static String inferTemplateId(String goalTitle) {
    final lower = goalTitle.toLowerCase();
    // Prioritize "Maker" keywords first (Project/Build)
    if (lower.contains('startup') || lower.contains('business') || lower.contains('launch')) return 'startup';
    if (lower.contains('money') || lower.contains('finance') || lower.contains('budget')) return 'finance';
    if (lower.contains('career') || lower.contains('job') || lower.contains('work')) return 'career';
    if (lower.contains('creative') || lower.contains('art') || lower.contains('write') || lower.contains('podcast')) return 'creative';
    if (lower.contains('travel') || lower.contains('trip') || lower.contains('vacation')) return 'travel';
    
    if (lower.contains('code') ||
        lower.contains('app') ||
        lower.contains('project') ||
        lower.contains('build') ||
        lower.contains('launch') ||
        lower.contains('bot')) return 'project';
    if (lower.contains('research') ||
        lower.contains('paper') ||
        lower.contains('thesis')) return 'research';
    // Learning comes after Project to avoid "build a study bot" being caught as Learning
    if (lower.contains('learn') ||
        lower.contains('study') ||
        lower.contains('course')) return 'learning';
    if (lower.contains('fitness') ||
        lower.contains('gym') ||
        lower.contains('weight') ||
        lower.contains('run')) return 'fitness';
    if (lower.contains('skin') ||
        lower.contains('hair') ||
        lower.contains('care')) return 'skincare';
    if (lower.contains('mood') ||
        lower.contains('journal') ||
        lower.contains('mental')) return 'mental';
    return 'daily'; // Default
  }
}
