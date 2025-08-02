import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TimerWidget extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onComplete;
  final bool autoStart;

  const TimerWidget({
    Key? key,
    this.durationSeconds = AppConstants.caseDurationSeconds,
    this.onComplete,
    this.autoStart = false,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _timer;
  int _currentSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.durationSeconds;
    
    _animationController = AnimationController(
      duration: Duration(seconds: widget.durationSeconds),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void start() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });

    _animationController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentSeconds--;
      });

      if (_currentSeconds <= 0) {
        _complete();
      }
    });
  }

  void pause() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    _animationController.stop();
    
    setState(() {
      _isRunning = false;
    });
  }

  void reset() {
    _timer?.cancel();
    _animationController.reset();
    
    setState(() {
      _currentSeconds = widget.durationSeconds;
      _isRunning = false;
    });
  }

  void _complete() {
    _timer?.cancel();
    _animationController.complete();
    
    setState(() {
      _isRunning = false;
      _currentSeconds = 0;
    });

    widget.onComplete?.call();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    double progress = _currentSeconds / widget.durationSeconds;
    if (progress > 0.5) {
      return AppColors.accent;
    } else if (progress > 0.2) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.divider.withOpacity(0.3),
                  ),
                ),
              ),
              // Progress circle
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                    ),
                  );
                },
              ),
              // Time text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_currentSeconds),
                    style: AppTextStyles.heading2.copyWith(
                      color: _getTimerColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'TIME LEFT',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isRunning && _currentSeconds > 0) ...[
              ElevatedButton.icon(
                onPressed: start,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                ),
              ),
            ] else if (_isRunning) ...[
              ElevatedButton.icon(
                onPressed: pause,
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Pause'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                ),
              ),
            ],
            if (_currentSeconds < widget.durationSeconds) ...[
              const SizedBox(width: AppDimensions.paddingSmall),
              OutlinedButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Getters for external access
  bool get isRunning => _isRunning;
  int get currentSeconds => _currentSeconds;
  Duration get timeSpent => Duration(seconds: widget.durationSeconds - _currentSeconds);
}