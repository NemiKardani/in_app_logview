import 'package:flutter/material.dart';
import 'package:in_app_logview/in_app_logview.dart';
import 'package:dio/dio.dart';
import 'dart:async';

void main() {
  // Initialize the log viewer with logger package integration
  // You can also use InAppLog.initialize() for default methods
  // or InAppLog.initialize(useLogger: true, printer: PrettyPrinter()) for custom printer
  InAppLog.initialize(useLogger: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'in_app_logview Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Wrap the home with LogViewWrapper to show the floating button
      home: const LogViewWrapper(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Timer? _autoLogTimer;
  Logger? _customLogger;
  late Dio _dio;

  @override
  void initState() {
    super.initState();

    // Add some initial logs using convenience methods
    InAppLog.info('App initialized');
    InAppLog.info('Welcome to in_app_logview example!', tag: 'Welcome');

    // Create a custom logger instance for demonstration
    _customLogger = InAppLog.createLogger();

    // Initialize Dio with InAppLogDioInterceptor
    _dio = Dio();
    _dio.interceptors.add(
      InAppLogDioInterceptor(
        tag: 'API',
        logRequest: true,
        logResponse: true,
        logError: true,
      ),
    );

    // Start auto-logging for demonstration
    _startAutoLogging();
  }

  @override
  void dispose() {
    _autoLogTimer?.cancel();
    super.dispose();
  }

  void _startAutoLogging() {
    _autoLogTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final messages = [
        'Auto log message #${timer.tick}',
        'Processing data...',
        'Network request completed',
        'User interaction detected',
      ];

      final index = timer.tick % messages.length;
      switch (index) {
        case 0:
          InAppLog.debug(messages[index], tag: 'AutoLogger');
          break;
        case 1:
          InAppLog.info(messages[index], tag: 'AutoLogger');
          break;
        case 2:
          InAppLog.warning(messages[index], tag: 'AutoLogger');
          break;
        case 3:
          InAppLog.error(messages[index], tag: 'AutoLogger');
          break;
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    // Use convenience method instead of addLog
    InAppLog.info('Counter incremented to $_counter', tag: 'Counter');
  }

  void _addDebugLog() {
    // Using convenience method
    InAppLog.debug('This is a debug message', tag: 'UserAction');
    _showSnackBar('Debug log added');
  }

  void _addInfoLog() {
    // Using convenience method
    InAppLog.info('This is an info message', tag: 'UserAction');
    _showSnackBar('Info log added');
  }

  void _addWarningLog() {
    // Using convenience method
    InAppLog.warning('This is a warning message', tag: 'UserAction');
    _showSnackBar('Warning log added');
  }

  void _addErrorLog() {
    // Using convenience method with error and stackTrace
    try {
      throw Exception('Example error for demonstration');
    } catch (e, stackTrace) {
      InAppLog.error(
        'This is an error message',
        tag: 'UserAction',
        error: e,
        stackTrace: stackTrace,
      );
    }
    _showSnackBar('Error log added');
  }

  void _addMultipleLogs() {
    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        InAppLog.info('Batch log message #$i', tag: 'Batch');
      } else {
        InAppLog.debug('Batch log message #$i', tag: 'Batch');
      }
    }
    _showSnackBar('10 logs added');
  }

  void _useCustomLogger() {
    // Demonstrate using a custom logger instance
    _customLogger?.d('Custom logger debug message');
    _customLogger?.i('Custom logger info message');
    _customLogger?.w('Custom logger warning message');
    _customLogger?.e('Custom logger error message');
    _showSnackBar('Custom logger messages added');
  }

  void _useDefaultLogger() {
    // Demonstrate using the default logger (if enabled)
    if (InAppLog.isUsingLogger && InAppLog.defaultLogger != null) {
      InAppLog.defaultLogger!.d('Default logger debug');
      InAppLog.defaultLogger!.i('Default logger info');
      InAppLog.defaultLogger!.w('Default logger warning');
      InAppLog.defaultLogger!.e('Default logger error');
      _showSnackBar('Default logger messages added');
    } else {
      _showSnackBar('Default logger not enabled');
    }
  }

  void _useAddLogMethod() {
    // Demonstrate using addLog for programmatic logging
    InAppLog.addLog(
      'Programmatic log entry',
      level: LogLevel.info,
      tag: 'Programmatic',
    );
    _showSnackBar('Programmatic log added');
  }

  Future<void> _makeApiCall() async {
    try {
      InAppLog.info('Making API call to JSONPlaceholder...', tag: 'API');

      // Make a GET request - this will be logged by the interceptor
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/todos/1',
      );

      InAppLog.info('API call successful: ${response.statusCode}', tag: 'API');
      _showSnackBar('API call successful (check logs)');
    } catch (e) {
      InAppLog.error('API call failed', tag: 'API', error: e);
      _showSnackBar('API call failed (check logs)');
    }
  }

  Future<void> _makeApiCallWithError() async {
    try {
      InAppLog.info('Making API call to invalid endpoint...', tag: 'API');

      // Make a request to an invalid endpoint to demonstrate error logging
      await _dio.get(
        'https://jsonplaceholder.typicode.com/invalid-endpoint-404',
      );
    } catch (e) {
      // Error will be logged by the interceptor
      _showSnackBar('API error logged (check logs)');
    }
  }

  Future<void> _makeApiCallWithPost() async {
    try {
      InAppLog.info('Making POST API call...', tag: 'API');

      // Make a POST request with data - this will be logged by the interceptor
      final response = await _dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          'title': 'Test Post',
          'body': 'This is a test post from in_app_logview example',
          'userId': 1,
        },
      );

      InAppLog.info(
        'POST request successful: ${response.statusCode}',
        tag: 'API',
      );
      _showSnackBar('POST request successful (check logs)');
    } catch (e) {
      InAppLog.error('POST request failed', tag: 'API', error: e);
      _showSnackBar('POST request failed (check logs)');
    }
  }

  void _openLogViewer() {
    InAppLog.open(context);
    InAppLog.info('Log viewer opened programmatically');
  }

  void _toggleLogViewer() {
    InAppLog.toggle(context);
  }

  void _closeLogViewer() {
    InAppLog.close();
    InAppLog.info('Log viewer closed programmatically');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('in_app_logview Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _openLogViewer,
            tooltip: 'Open Log Viewer',
          ),
          IconButton(
            icon: const Icon(Icons.toggle_on),
            onPressed: _toggleLogViewer,
            tooltip: 'Toggle Log Viewer',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeLogViewer,
            tooltip: 'Close Log Viewer',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'in_app_logview Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Counter: $_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),
              const Text(
                'Basic Logging Methods:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add),
                    label: const Text('Increment Counter'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addDebugLog,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Debug'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addInfoLog,
                    icon: const Icon(Icons.info),
                    label: const Text('Info'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addWarningLog,
                    icon: const Icon(Icons.warning),
                    label: const Text('Warning'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addErrorLog,
                    icon: const Icon(Icons.error),
                    label: const Text('Error'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Advanced Features:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addMultipleLogs,
                    icon: const Icon(Icons.list),
                    label: const Text('Add 10 Logs'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _useCustomLogger,
                    icon: const Icon(Icons.build),
                    label: const Text('Custom Logger'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _useDefaultLogger,
                    icon: const Icon(Icons.settings),
                    label: const Text('Default Logger'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _useAddLogMethod,
                    icon: const Icon(Icons.code),
                    label: const Text('AddLog Method'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Dio Interceptor Examples:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _makeApiCall,
                    icon: const Icon(Icons.http),
                    label: const Text('GET Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _makeApiCallWithPost,
                    icon: const Icon(Icons.send),
                    label: const Text('POST Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _makeApiCallWithError,
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Error Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instructions:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Tap the floating bug button (bottom right) to open the log viewer',
                      ),
                      const Text(
                        '• Use app bar icons to open/toggle/close the log viewer',
                      ),
                      const Text(
                        '• Use the buttons above to add different types of logs',
                      ),
                      const Text(
                        '• The log viewer supports search, filtering, and copying',
                      ),
                      const Text(
                        '• Auto-logging runs every 3 seconds for demonstration',
                      ),
                      const Text(
                        '• Use Dio interceptor buttons to test API request/response logging',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Logger package enabled: ${InAppLog.isUsingLogger}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        '• Log viewer enabled: ${InAppLog.isEnabled}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        '• Log viewer open: ${InAppLog.isOpen}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
