import 'dart:ui' as ui;

import 'package:awesome_pdf_viewer/src/debouncer.dart';
import 'package:awesome_pdf_viewer/src/slider_thumb_image.dart';
import 'package:awesome_pdf_viewer/src/slider_track_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

/// An awesome PDF viewer widget that displays PDF files within a Flutter application.
///
/// This widget takes in the path of the PDF to be displayed and provides various
/// features like sharing, printing, and navigation.
class AwesomePdfViewer extends StatefulWidget {
  /// Creates an instance of AwesomePdfViewer.
  ///
  /// The [pdfPath] parameter must not be null and represents the path to the PDF file.
  /// Creates an instance of AwesomePdfViewer.
  ///
  /// The [pdfPath] parameter must not be null and represents the path to the PDF file.
  const AwesomePdfViewer({
    super.key,
    required this.pdfPath,
    this.appBarTitle,
    this.backgroundColor,
    this.elevation,
    this.centerTitle,
    this.iconTheme,
    this.titleTextStyle,
    this.primary,
    this.brightness,
    this.flexibleSpace,
    this.bottom,
    this.toolbarOpacity,
    this.bottomOpacity,
    this.toolbarHeight,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.shape,
  });

  /// The path or URL to the PDF file that needs to be displayed.
  final String pdfPath;

  /// An optional title for the AppBar. If not provided, 'PDF Viewer' will be used.
  final Text? appBarTitle;

  /// Background color of the AppBar.
  final Color? backgroundColor;

  /// Elevation of the AppBar.
  final double? elevation;

  /// Whether the title should be centered.
  final bool? centerTitle;

  /// Theme for icons on the AppBar.
  final IconThemeData? iconTheme;

  /// The title text style for the AppBar.
  final TextStyle? titleTextStyle;

  /// Whether this app bar is being displayed at the top of the screen.
  final bool? primary;

  /// The brightness of the app bar's material.
  final Brightness? brightness;

  /// This widget is stacked behind the toolbar and the tab bar.
  final Widget? flexibleSpace;

  /// This widget appears across the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// How opaque the toolbar part of the app bar is.
  final double? toolbarOpacity;

  /// How opaque the bottom part of the app bar is.
  final double? bottomOpacity;

  /// Defines the height of the toolbar part of the app bar.
  final double? toolbarHeight;

  /// A widget to display before the app bar's [title].
  final Widget? leading;

  /// Whether to show a leading widget, typically a back button.
  final bool automaticallyImplyLeading;

  /// Widgets to display after the title widget.
  final List<Widget>? actions;

  /// The shape of the app bar's material's shape as well its shadow.
  final ShapeBorder? shape;

  @override
  State<AwesomePdfViewer> createState() => _AwesomePdfViewer();
}

class _AwesomePdfViewer extends State<AwesomePdfViewer>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final PdfController _pdfController;
  late final AnimationController _animationController;

  // State variables
  final FocusNode _focusNode = FocusNode();
  List<PdfPageImage> _thumbnailImageList = [];
  ui.Image? _sliderImage;
  int _currentPage = 1;
  bool _isDragging = false;
  bool _pageIsActive = true;

  // Debouncers for delaying resize and slider image update
  final _resizeScreenDebouncer =
      Debouncer(delay: const Duration(milliseconds: 500));
  final _sliderImageDebouncer =
      Debouncer(delay: const Duration(milliseconds: 100));

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // Initialize the page
  void _initializePage() {
    _pageIsActive = true;
    WidgetsBinding.instance.addObserver(this);
    _pdfController = _createPdfController();
    _animationController = _createAnimationController();
    _generateInitialSliderImages();
    _setInitialPageImage();
  }

  // Create PDF Controller
  PdfController _createPdfController() {
    return PdfController(
      document: _getDocument(),
    );
  }

  // Create Animation Controller
  AnimationController _createAnimationController() {
    return AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  // Generate initial images for the slider
  void _generateInitialSliderImages() {
    _generateSliderImages(
      PlatformDispatcher.instance.views.first.physicalSize.width,
    );
  }

  // Set initial page image
  void _setInitialPageImage() {
    _getPageImage(_currentPage);
  }

  // Dispose page and controllers
  void _disposePage() {
    _pageIsActive = false;
    _pdfController.dispose();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void dispose() {
    _disposePage();
    super.dispose();
  }

  // Resize screen and regenerate thumbnails
  @override
  void didChangeMetrics() {
    if (_pageIsActive) {
      _resizeScreenDebouncer.run(() {
        _generateSliderImages(
          PlatformDispatcher.instance.views.first.physicalSize.width,
        );
      });
    }
    super.didChangeMetrics();
  }

  // Convert PdfPageImage to ui.Image
  Future<ui.Image> _getUiImage(Uint8List byteData) async {
    final codec = await ui.instantiateImageCodec(byteData);
    return (await codec.getNextFrame()).image;
  }

  // Retrieve PDF document from the path
  Future<PdfDocument> _getDocument() async {
    if (Uri.parse(widget.pdfPath).isAbsolute) {
      return PdfDocument.openData(InternetFile.get(widget.pdfPath));
    } else if (widget.pdfPath.startsWith('assets/')) {
      return PdfDocument.openAsset(widget.pdfPath);
    } else {
      return PdfDocument.openFile(widget.pdfPath);
    }
  }

  // Generate thumbnails for the slider
  Future<void> _generateSliderImages(double width) async {
    // Get the document from the given path
    final document = await _pdfController.document;

    // Total number of pages in the document
    final pageCount = document.pagesCount;

    // Calculate the number of thumbnails to generate based on the screen width
    final thumbnailCount = (width / 130).round().clamp(0, pageCount);

    // Generate a list of points (page numbers) for which to capture thumbnails
    final points = _calculateThumbnailPoints(pageCount, thumbnailCount);

    // Generate thumbnail images
    final imageList = await _generateThumbnails(document, points);

    // Update the thumbnail list in the state
    if (mounted) {
      // <-- Check if the widget is still mounted
      setState(() {
        _thumbnailImageList = imageList;
      });
    }
  }

// Calculate thumbnail points based on the number of pages and required thumbnails
  List<double> _calculateThumbnailPoints(int pageCount, int thumbnailCount) {
    if (thumbnailCount <= 1) {
      return [1.0]; // or return a value that makes sense in your context
    }

    return List<double>.generate(
      thumbnailCount,
      (i) => 1.0 + i * ((pageCount - 1) / (thumbnailCount - 1)),
    );
  }

// Generate thumbnails for given points (page numbers)
  Future<List<PdfPageImage>> _generateThumbnails(
      PdfDocument document, List<double> points) async {
    final imageList = <PdfPageImage>[];
    for (final point in points) {
      final page = await document.getPage(point.round());
      try {
        final pageImage = await page.render(
          width: page.width / 10,
          height: page.height / 10,
        );
        if (pageImage != null) {
          imageList.add(pageImage);
        }
      } finally {
        await page.close();
      }
    }
    return imageList;
  }

// Fetch image of a specific page number
  Future<void> _getPageImage(int pageNum) async {
    final document = await _pdfController.document;
    final page = await document.getPage(pageNum);
    try {
      final image = await page.render(
        width: page.width / 10,
        height: page.height / 10,
      );
      if (image != null) {
        final newImg = await _getUiImage(image.bytes);
        setState(() {
          _sliderImage = newImg;
        });
      }
    } finally {
      await page.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.appBarTitle ?? const Text('PDF Viewer'),
        backgroundColor: widget.backgroundColor,
        elevation: widget.elevation,
        centerTitle: widget.centerTitle,
        iconTheme: widget.iconTheme,
        titleTextStyle: widget.titleTextStyle,
        primary: widget.primary ?? true,
        flexibleSpace: widget.flexibleSpace,
        bottom: widget.bottom,
        toolbarOpacity: widget.toolbarOpacity ?? 1.0,
        bottomOpacity: widget.bottomOpacity ?? 1.0,
        toolbarHeight: widget.toolbarHeight,
        leading: widget.leading,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        actions: widget.actions ??
            [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Theme.of(context).platform == TargetPlatform.android
                      ? Icons.share
                      : Icons.ios_share,
                ),
                onPressed: () async {
                  // ... (Your previous code remains unchanged)
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.print,
                ),
                onPressed: () async {
                  // ... (Your previous code remains unchanged)
                },
              ),
            ],
        shape: widget.shape,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RawKeyboardListener(
              autofocus: true,
              focusNode: _focusNode,
              onKey: (value) async {
                try {
                  if (kIsWeb) {
                    if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
                      await _pdfController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeIn,
                      );
                    } else if (value.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      await _pdfController.previousPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeIn,
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('arrow error ---> $e');
                }

                // setState(() {});
              },
              child: PdfView(
                builders: PdfViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) =>
                      const Center(child: CupertinoActivityIndicator()),
                  pageLoaderBuilder: (_) =>
                      const Center(child: CupertinoActivityIndicator()),
                  errorBuilder: (_, error) =>
                      Center(child: Text(error.toString())),
                ),
                onPageChanged: (page) async {
                  await _getPageImage(page);
                  setState(() {
                    _currentPage = page;
                  });
                },
                controller: _pdfController,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PdfPageNumber(
                  controller: _pdfController,
                  builder: (_, loadingState, page, pagesCount) {
                    if (pagesCount == null || _thumbnailImageList.isEmpty) {
                      return Container();
                    }
                    return Center(
                      child: Container(
                        height: 60,
                        width: _thumbnailImageList.length * 37,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              child: Align(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 30,
                                      color: Theme.of(context).cardColor,
                                      child: _thumbnailImageList.isEmpty ||
                                              _thumbnailImageList.length <=
                                                  index
                                          ? const CupertinoActivityIndicator()
                                          : Image(
                                              image: MemoryImage(
                                                _thumbnailImageList[index]
                                                    .bytes,
                                              ),
                                            ),
                                    );
                                  },
                                  itemCount: _thumbnailImageList.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 5, width: 5),
                                ),
                              ),
                            ),
                            if (pagesCount != 1)
                              SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: SliderThumbImage(
                                    image: _sliderImage,
                                    isDragging: _isDragging,
                                    rotation: _animationController.value,
                                  ),
                                  overlayShape: SliderComponentShape.noOverlay,
                                  trackHeight: 0,
                                  trackShape: CustomTrackShape(),
                                ),
                                child: Slider(
                                  value: _currentPage.toDouble(),
                                  max: pagesCount.toDouble(),
                                  min: 1,
                                  label: _currentPage.toString(),
                                  onChanged: (double value) {
                                    final pageNum = value.round();
                                    setState(() {
                                      _sliderImage = null;
                                      _isDragging = true;
                                      _currentPage = pageNum;
                                    });
                                    _sliderImageDebouncer.run(
                                      () => _getPageImage(value.round()),
                                    );
                                  },
                                  onChangeEnd: (double value) {
                                    final pageNum = value.round();
                                    _pdfController.jumpToPage(
                                      pageNum,
                                    );
                                    setState(() {
                                      _isDragging = false; // <-- Set to false
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
