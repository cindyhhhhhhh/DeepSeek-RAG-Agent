import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 随身助理',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _response;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 120),
    sendTimeout: const Duration(seconds: 10),
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:8000/analyze');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final summary = data['summary'] as String?;
        final actionItems = (data['action_items'] as List?)?.map((e) => e.toString()).toList();
        if (summary == null || actionItems == null) {
          throw Exception('返回 JSON 缺少 summary 或 action_items 字段');
        }
        final formatted = '摘要：' + summary + '\n\n行动建议：\n- ' + actionItems.join('\n- ');
        setState(() {
          _response = formatted;
        });
      } else {
        throw Exception('服务错误：${res.statusCode}');
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请求超时，请检查服务是否运行或网络连接')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请求失败：${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path!, filename: file.name),
        });

        final response = await _dio.post('http://10.0.2.2:8000/upload', data: formData);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文档解析成功')),
          );
        } else {
          throw Exception('上传失败: ${response.statusCode}');
        }
      } else {
        // User canceled the picker
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传出错: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 随身助理'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.attach_file, size: 28),
                    tooltip: '上传文档',
                    onPressed: _uploadFile,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.attach_file, size: 28),
                    tooltip: '上传文档',
                    onPressed: _uploadFile,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: '在此输入你的内容',
                    hintText: '请输入要分析的笔记或想法',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _analyze,
                    child: const Text('智能分析'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_loading) const Center(child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    CircularProgressIndicator(),
    SizedBox(height: 16),
    Text('正在阅读文档并深入思考，这可能需要1分钟，请耐心等待...'),
  ],
)),
                if (!_loading && _response != null) ...[
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI 回复',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_response ?? ''),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}