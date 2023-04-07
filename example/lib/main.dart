import 'package:flutter/material.dart';
import 'package:awesome_pdf_viewer/awesome_pdf_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Awesome PDF Viewer'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required title}) : _title = title;

  final String _title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AwesomePdfViewer(
                            pdfPath: 'assets/test_mass_page.pdf',
                          )),
                );
              },
              child: const SizedBox(
                height: 50,
                child: Center(child: Text('PDF Large')),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AwesomePdfViewer(
                          pdfPath: 'assets/test_multi_page.pdf',
                        )),
              ),
              child: const SizedBox(
                height: 50,
                child: Center(child: Text('PDF Medium')),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AwesomePdfViewer(
                          pdfPath: 'assets/test_single_page.pdf',
                        )),
              ),
              child: const SizedBox(
                height: 50,
                child: Center(child: Text('PDF Small')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
