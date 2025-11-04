import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/models.dart';

/// Activity Calendar Widget - Shows monthly calendar with training activity indicators
class ActivityCalendarWidget extends StatefulWidget {
  const ActivityCalendarWidget({
    super.key,
    required this.events,
  });

  final List<ProgressEvent> events;

  @override
  State<ActivityCalendarWidget> createState() => _ActivityCalendarWidgetState();
}

class _ActivityCalendarWidgetState extends State<ActivityCalendarWidget> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and navigation
            Row(
              children: [
                Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const Spacer(),
                // Month navigation
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 28,
                  color: Colors.grey[400],
                  onPressed: _previousMonth,
                ),
                Text(
                  _formatMonthYear(_selectedMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[300],
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 28,
                  color: Colors.grey[400],
                  onPressed: _nextMonth,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Calendar grid
            _buildCalendar(),

            const SizedBox(height: 16),

            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    // Get the first day of the month
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    
    // Get the last day of the month
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    // Get the starting weekday (0 = Monday, 6 = Sunday)
    final startWeekday = firstDayOfMonth.weekday - 1;
    
    // Calculate total cells needed
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    // Get training days in this month
    final trainingDays = _getTrainingDaysInMonth();

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeekdayHeader('M'),
            _buildWeekdayHeader('T'),
            _buildWeekdayHeader('W'),
            _buildWeekdayHeader('T'),
            _buildWeekdayHeader('F'),
            _buildWeekdayHeader('S'),
            _buildWeekdayHeader('S'),
          ],
        ),
        
        const SizedBox(height: 8),

        // Calendar grid
        ...List.generate(rows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNumber = cellIndex - startWeekday + 1;

                // Empty cell before month starts or after month ends
                if (cellIndex < startWeekday || dayNumber > daysInMonth) {
                  return _buildEmptyDayCell();
                }

                final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                final hasTraining = trainingDays.contains(dayNumber);
                final isToday = _isToday(date);
                final sessionCount = _getSessionCountForDay(dayNumber);

                return _buildDayCell(
                  dayNumber,
                  hasTraining,
                  isToday,
                  sessionCount,
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeekdayHeader(String label) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildEmptyDayCell() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Container(),
    );
  }

  Widget _buildDayCell(int day, bool hasTraining, bool isToday, int sessionCount) {
    final sessionTypes = _getSessionTypesForDay(day);
    final hasProgramSessions = sessionTypes['program']! > 0;
    final hasExtraSessions = sessionTypes['extra']! > 0;
    final hasBothTypes = hasProgramSessions && hasExtraSessions;
    
    Color textColor;
    
    if (hasTraining) {
      textColor = Colors.white;
    } else {
      textColor = Colors.grey[600]!;
    }

    Widget cellContent;
    
    if (!hasTraining) {
      // No training - simple grey cell
      cellContent = Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppTheme.accentColor, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      );
    } else if (hasBothTypes) {
      // Both program and extra - split diagonal
      cellContent = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppTheme.accentColor, width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isToday ? 6 : 8),
          child: Stack(
            children: [
              // Bottom-left triangle (Program - Blue)
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrianglePainter(
                    color: Colors.blue,
                    isBottomLeft: true,
                  ),
                ),
              ),
              // Top-right triangle (Extra - Purple)
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrianglePainter(
                    color: Colors.purple,
                    isBottomLeft: false,
                  ),
                ),
              ),
              // Day number centered
              Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (hasProgramSessions) {
      // Only program sessions - Blue with intensity
      Color cellColor;
      if (sessionTypes['program']! >= 3) {
        cellColor = Colors.blue;
      } else if (sessionTypes['program']! == 2) {
        cellColor = Colors.blue.withOpacity(0.7);
      } else {
        cellColor = Colors.blue.withOpacity(0.5);
      }
      
      cellContent = Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppTheme.accentColor, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      );
    } else {
      // Only extra sessions - Purple with intensity
      Color cellColor;
      if (sessionTypes['extra']! >= 3) {
        cellColor = Colors.purple;
      } else if (sessionTypes['extra']! == 2) {
        cellColor = Colors.purple.withOpacity(0.7);
      } else {
        cellColor = Colors.purple.withOpacity(0.5);
      }
      
      cellContent = Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppTheme.accentColor, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: cellContent,
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        // First row: Session types
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Program', Colors.blue),
            const SizedBox(width: 16),
            _buildLegendItem('Extra', Colors.purple),
            const SizedBox(width: 16),
            _buildLegendItemSplit('Both', Colors.blue, Colors.purple),
          ],
        ),
        const SizedBox(height: 8),
        // Second row: Intensity
        Text(
          'Color intensity shows session count (lighter = less, brighter = more)',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItemSplit(String label, Color color1, Color color2) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrianglePainter(
                      color: color1,
                      isBottomLeft: true,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrianglePainter(
                      color: color2,
                      isBottomLeft: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Set<int> _getTrainingDaysInMonth() {
    final trainingDays = <int>{};
    
    for (final event in widget.events) {
      // Only consider session and extra completions
      if (event.type == ProgressEventType.sessionCompleted ||
          event.type == ProgressEventType.extraCompleted) {
        // Check if event is in selected month
        if (event.ts.year == _selectedMonth.year &&
            event.ts.month == _selectedMonth.month) {
          trainingDays.add(event.ts.day);
        }
      }
    }

    return trainingDays;
  }

  int _getSessionCountForDay(int day) {
    int count = 0;
    
    for (final event in widget.events) {
      if (event.type == ProgressEventType.sessionCompleted ||
          event.type == ProgressEventType.extraCompleted) {
        if (event.ts.year == _selectedMonth.year &&
            event.ts.month == _selectedMonth.month &&
            event.ts.day == day) {
          count++;
        }
      }
    }

    return count;
  }

  Map<String, int> _getSessionTypesForDay(int day) {
    int programCount = 0;
    int extraCount = 0;
    
    for (final event in widget.events) {
      if (event.ts.year == _selectedMonth.year &&
          event.ts.month == _selectedMonth.month &&
          event.ts.day == day) {
        if (event.type == ProgressEventType.sessionCompleted) {
          programCount++;
        } else if (event.type == ProgressEventType.extraCompleted) {
          extraCount++;
        }
      }
    }

    return {
      'program': programCount,
      'extra': extraCount,
    };
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    // Don't allow navigating to future months
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    final now = DateTime.now();
    
    if (nextMonth.year < now.year || 
        (nextMonth.year == now.year && nextMonth.month <= now.month)) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Custom painter to draw diagonal triangle splits for mixed session days
class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isBottomLeft;

  _TrianglePainter({
    required this.color,
    required this.isBottomLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isBottomLeft) {
      // Bottom-left triangle
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Top-right triangle
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
