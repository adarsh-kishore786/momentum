class MonthlyAggregate {
  final int projectId;
  final String projectName;
  final int year;
  final int month;
  final int totalMinutes;

  const MonthlyAggregate({
    required this.projectId,
    required this.projectName,
    required this.year,
    required this.month,
    required this.totalMinutes
  }) : assert(projectId > 0, 'Project ID must be a valid ID'),
       assert(projectName.length > 0, 'Project name cannot be empty'),
       assert(year >= 2026, 'Year doesn\'t seem right'), 
       assert(month >= 1 && month <= 12, 'month must be 1-12'),
       assert(totalMinutes > 0, 'totalMinutes must be positive');

  factory MonthlyAggregate.fromMap(Map<String, dynamic> map) {
    return MonthlyAggregate(
      projectId: map['project_id'] as int,
      projectName: map['project_name'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      totalMinutes: map['total_minutes'] as int
    );
  }
}
