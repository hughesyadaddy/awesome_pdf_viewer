# Awesome PDF Viewer

[![GitHub stars](https://img.shields.io/github/stars/hughesyadaddy/awesome_pdf_viewer.svg?style=social)](https://github.com/hughesyadaddy/awesome_pdf_viewer/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/hughesyadaddy/awesome_pdf_viewer.svg?style=social)](https://github.com/hughesyadaddy/awesome_pdf_viewer/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/hughesyadaddy/awesome_pdf_viewer.svg?style=social)](https://github.com/hughesyadaddy/awesome_pdf_viewer/watchers)
[![GitHub issues](https://img.shields.io/github/issues/hughesyadaddy/awesome_pdf_viewer.svg)](https://github.com/hughesyadaddy/awesome_pdf_viewer/issues)
[![GitHub license](https://img.shields.io/github/license/hughesyadaddy/awesome_pdf_viewer.svg)](https://github.com/hughesyadaddy/awesome_pdf_viewer/blob/master/LICENSE)

Awesome PDF Viewer is a Flutter package that allows you to display PDF documents within your Flutter application.

## Installation

Add `awesome_pdf_viewer` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  awesome_pdf_viewer:
    git: https://github.com/hughesyadaddy/awesome_pdf_viewer.git
```
Then, run flutter pub get in your terminal to install the package.

## Usage

1. Add your PDF file to the `assets` directory of your Flutter project.

2. Open the `pubspec.yaml` file in your Flutter project and add the following code:

   ```yaml
   flutter:
     assets:
       - assets/my_document.pdf
    ```
    Replace my_document.pdf with the actual name of your PDF file.

3. Import the package in your Dart code:
   ```dart 
   import 'package:awesome_pdf_viewer/awesome_pdf_viewer.dart';
   ```
4. Open a PDF document:
    ```dart
     Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AwesomePdfViewer(
                                pdfPath: 'assets/my_document.pdf',
                              )),
                    );
    ```

## Example

See the example directory for a complete sample app using Awesome PDF Viewer.

## License

This project is licensed under the MIT License.
