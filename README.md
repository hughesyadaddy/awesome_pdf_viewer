# Awesome Pdf Viewer

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A Awesome PDF Viewer with easy navigation, sharing, and print

## Installation 💻

**❗ In order to start using Awesome Pdf Viewer you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add `awesome_pdf_viewer` to your `pubspec.yaml`:

```yaml
dependencies:
  awesome_pdf_viewer:
    git:
      url: https://github.com/hughesyadaddy/awesome_pdf_viewer.git
```

## Push the Awesome PDF View page with a path to a Pdf Asset.

Add the AwesomePdfViewer page to your navigator and push with a argument PdfPath pointing to your Pdf Asset File.

```dart
 Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AwesomePdfViewer(
                            pdfPath: 'assets/test_mass_page.pdf',
                          )),
                );
```
