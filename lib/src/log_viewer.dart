import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'log_capture.dart';
import 'log_view_overlay.dart';
import 'models/log_entry.dart';

/// The main log viewer widget that displays logs in a console-like interface.
class LogViewer extends StatefulWidget {
  const LogViewer({super.key});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<LogEntry> _filteredLogs = [];
  LogLevel? _selectedLevel;
  bool _autoScroll = true;
  bool _showDateTime = true;
  bool _showLogLevel = true;
  bool _showApiOnly = false;
  double _fontSize = 11.0;
  static const double _minFontSize = 8.0;
  static const double _maxFontSize = 20.0;
  static const double _fontSizeStep = 1.0;
  StreamSubscription<LogEntry>? _logSubscription;

  @override
  void initState() {
    super.initState();
    _updateFilteredLogs();
    _logSubscription = LogCapture().logStream.listen((entry) {
      if (mounted) {
        setState(() {
          _updateFilteredLogs();
          if (_autoScroll) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        });
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _logSubscription?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _updateFilteredLogs();
    });
  }

  void _updateFilteredLogs() {
    final allLogs = LogCapture().logs;
    final searchText = _searchController.text.toLowerCase();

    _filteredLogs.clear();
    _filteredLogs.addAll(allLogs.where((log) {
      final matchesSearch = searchText.isEmpty ||
          log.message.toLowerCase().contains(searchText) ||
          (log.tag?.toLowerCase().contains(searchText) ?? false);

      final matchesLevel =
          _selectedLevel == null || log.level == _selectedLevel;

      final matchesApiFilter = !_showApiOnly || log.tag?.toUpperCase() == 'API';

      return matchesSearch && matchesLevel && matchesApiFilter;
    }));
  }

  void _toggleAutoScroll() {
    setState(() {
      _autoScroll = !_autoScroll;
      if (_autoScroll && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() {
    LogCapture().clearLogs();
    setState(() {
      _updateFilteredLogs();
    });
  }

  Future<void> _copyLogs() async {
    final text = _filteredLogs
        .map((log) => _showDateTime
            ? log.formattedMessage
            : log.formattedMessageWithoutTime)
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logs copied to clipboard')),
      );
    }
  }

  void _toggleDateTime() {
    setState(() {
      _showDateTime = !_showDateTime;
    });
  }

  void _toggleLogLevel(LogLevel? level) {
    setState(() {
      if (_selectedLevel == level) {
        // Deselect if already selected
        _selectedLevel = null;
      } else {
        _selectedLevel = level;
      }
      _updateFilteredLogs();
    });
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < _maxFontSize) {
        _fontSize =
            (_fontSize + _fontSizeStep).clamp(_minFontSize, _maxFontSize);
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > _minFontSize) {
        _fontSize =
            (_fontSize - _fontSizeStep).clamp(_minFontSize, _maxFontSize);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: isMobile
              ? screenWidth * 0.95
              : isTablet
                  ? screenWidth * 0.85
                  : 900,
          height: isMobile
              ? screenHeight * 0.9
              : isTablet
                  ? screenHeight * 0.85
                  : 700,
          constraints: BoxConstraints(
            minWidth: 300,
            maxWidth: 1200,
            minHeight: 400,
            maxHeight: screenHeight * 0.95,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with controls
              _buildHeader(isMobile),
              // Search and filter bar
              _buildSearchBar(isMobile),
              // Log level filter chips
              if (_showLogLevel)
                _buildLogLevelFilters() ?? const SizedBox.shrink(),
              // Log list
              Expanded(child: _buildLogList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Log Viewer',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!isMobile) ...[
            // Font size controls
            IconButton(
              icon: const Icon(Icons.text_decrease, color: Colors.white70),
              onPressed: _decreaseFontSize,
              tooltip: 'Decrease font size',
              iconSize: 18,
            ),
            Text(
              '${_fontSize.toInt()}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            IconButton(
              icon: const Icon(Icons.text_increase, color: Colors.white70),
              onPressed: _increaseFontSize,
              tooltip: 'Increase font size',
              iconSize: 18,
            ),
            const SizedBox(width: 4),
          ],
          IconButton(
            icon: Icon(
              _autoScroll ? Icons.pause : Icons.play_arrow,
              color: Colors.white70,
            ),
            onPressed: _toggleAutoScroll,
            tooltip: _autoScroll ? 'Pause auto-scroll' : 'Resume auto-scroll',
            iconSize: isMobile ? 18 : 24,
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
            iconSize: isMobile ? 18 : 24,
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70),
            onPressed: _copyLogs,
            tooltip: 'Copy logs to clipboard',
            iconSize: isMobile ? 18 : 24,
          ),
          if (isMobile)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              color: const Color(0xFF3C3C3C),
              onSelected: (value) {
                switch (value) {
                  case 'decrease':
                    _decreaseFontSize();
                    break;
                  case 'increase':
                    _increaseFontSize();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'decrease',
                  child: Row(
                    children: [
                      const Icon(Icons.text_decrease,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text('Decrease font (${_fontSize.toInt()})',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'increase',
                  child: Row(
                    children: [
                      const Icon(Icons.text_increase,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text('Increase font (${_fontSize.toInt()})',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => LogViewOverlay.close(),
            tooltip: 'Close log viewer',
            iconSize: isMobile ? 18 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      color: const Color(0xFF252526),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: isMobile ? 11 : 12,
              ),
              decoration: InputDecoration(
                hintText: 'Search logs...',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54, size: 20),
                filled: true,
                fillColor: const Color(0xFF3C3C3C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                isDense: isMobile,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 4 : 8),
          // Filter toggle button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3C3C3C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list_alt,
                color: _getLogLevelColor(_selectedLevel ?? LogLevel.debug),
                size: isMobile ? 18 : 20,
              ),
              onPressed: () => setState(() {
                _showLogLevel = !_showLogLevel;
              }),
              tooltip: 'Filter logs by level',
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              constraints: const BoxConstraints(),
            ),
          ),
          SizedBox(width: isMobile ? 2 : 4),
          // Show API only toggle button
          Container(
            decoration: BoxDecoration(
              color: _showApiOnly
                  ? const Color(0xFF4A4A4A)
                  : const Color(0xFF3C3C3C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: Icon(
                Icons.api,
                color: _showApiOnly ? Colors.white : Colors.white54,
                size: isMobile ? 18 : 20,
              ),
              onPressed: () => setState(() {
                _showApiOnly = !_showApiOnly;
                _updateFilteredLogs();
              }),
              tooltip: _showApiOnly ? 'Show all logs' : 'Show API logs only',
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              constraints: const BoxConstraints(),
            ),
          ),
          SizedBox(width: isMobile ? 2 : 4),
          // Show date/time toggle button
          Container(
            decoration: BoxDecoration(
              color: _showDateTime
                  ? const Color(0xFF4A4A4A)
                  : const Color(0xFF3C3C3C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: Icon(
                Icons.access_time,
                color: _showDateTime ? Colors.white : Colors.white54,
                size: isMobile ? 18 : 20,
              ),
              onPressed: _toggleDateTime,
              tooltip:
                  _showDateTime ? 'Hide date and time' : 'Show date and time',
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildLogLevelFilters() {
    return _showLogLevel
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF252526),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // All Levels chip
                  _buildFilterChip(
                    label: 'All',
                    isSelected: _selectedLevel == null,
                    onTap: () => _toggleLogLevel(null),
                    color: _getLogLevelColor(LogLevel.debug),
                  ),
                  const SizedBox(width: 8),
                  // Debug chip
                  _buildFilterChip(
                    label: 'DEBUG',
                    isSelected: _selectedLevel == LogLevel.debug,
                    onTap: () => _toggleLogLevel(LogLevel.debug),
                    color: _getLogLevelColor(LogLevel.debug),
                  ),
                  const SizedBox(width: 8),
                  // Info chip
                  _buildFilterChip(
                    label: 'INFO',
                    isSelected: _selectedLevel == LogLevel.info,
                    onTap: () => _toggleLogLevel(LogLevel.info),
                    color: _getLogLevelColor(LogLevel.info),
                  ),
                  const SizedBox(width: 8),
                  // Warning chip
                  _buildFilterChip(
                    label: 'WARNING',
                    isSelected: _selectedLevel == LogLevel.warning,
                    onTap: () => _toggleLogLevel(LogLevel.warning),
                    color: _getLogLevelColor(LogLevel.warning),
                  ),
                  const SizedBox(width: 8),
                  // Error chip
                  _buildFilterChip(
                    label: 'ERROR',
                    isSelected: _selectedLevel == LogLevel.error,
                    onTap: () => _toggleLogLevel(LogLevel.error),
                    color: _getLogLevelColor(LogLevel.error),
                  ),
                ],
              ),
            ),
          )
        : null;
  }

  Color _getLogLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return const Color(0xFF9E9E9E);
      case LogLevel.info:
        return const Color(0xFF2196F3);
      case LogLevel.warning:
        return const Color(0xFFFF9800);
      case LogLevel.error:
        return const Color(0xFFF44336);
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.3)
              : const Color(0xFF3C3C3C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLogList() {
    if (_filteredLogs.isEmpty) {
      return const Center(
        child: Text(
          'No logs to display',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildLogItem(LogEntry log) {
    final color = Color(log.level.colorValue);
    final displayText =
        _showDateTime ? log.formattedMessage : log.formattedMessageWithoutTime;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SelectableText(
        displayText,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: _fontSize,
          height: 1.4,
        ),
      ),
    );
  }
}
