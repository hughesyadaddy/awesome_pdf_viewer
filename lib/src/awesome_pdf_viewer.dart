import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:async/async.dart';
import 'package:awesome_pdf_viewer/src/debouncer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scidart/numdart.dart';

class AwesomePdfViewer extends StatefulWidget {
  const AwesomePdfViewer({
    super.key,
    required this.pdfPath,
  });

  final String pdfPath;

  @override
  State<AwesomePdfViewer> createState() => _PdfPageState();
}

class _PdfPageState extends State<AwesomePdfViewer>
    with WidgetsBindingObserver {
  List<PdfPageImage> _thumbnailImageList = [];
  late final PdfController _pdfController;
  late final PdfController _pdfControllerSlider;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  Future<void> _generateSliderImages(double width) async {
    final imageList = <PdfPageImage>[];
    final document = await PdfDocument.openAsset(widget.pdfPath);
    final pagesCount = document.pagesCount;
    final thumbnailCount = pagesCount >= (width / 130).round()
        ? (width / 130).round()
        : pagesCount;
    print('We have $thumbnailCount thumnails');
    final evenlySpacedArrayPoints = linspace(
      1,
      pagesCount.toDouble(),
      num: thumbnailCount,
      endpoint: pagesCount != 1,
    );

    for (final invidualPoint in evenlySpacedArrayPoints) {
      final page = await document.getPage(invidualPoint.round());
      final pageImage =
          await page.render(width: page.width / 20, height: page.height / 20);
      await page.close();
      imageList.add(pageImage!);
    }
    await document.close();

    setState(() {
      _thumbnailImageList = imageList;
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.pdfPath);
    WidgetsBinding.instance.addObserver(this);
    _pdfController = PdfController(
      document: PdfDocument.openAsset(
        widget.pdfPath,
      ),
    );
    _pdfControllerSlider = PdfController(
      document: PdfDocument.openAsset(
        widget.pdfPath,
      ),
    );
    _generateSliderImages(WidgetsBinding.instance.window.physicalSize.width);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _pdfControllerSlider.dispose();
    _debouncer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _debouncer.run(() => _generateSliderImages(
          WidgetsBinding.instance.window.physicalSize.width,
        ));
    print(
        'didChangeMetrics new width: ${WidgetsBinding.instance.window.physicalSize.width}');
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome PDF Viewer'),
      ),
      body: Stack(
        children: [
          PdfView(
            builders: PdfViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) =>
                  const Center(child: CupertinoActivityIndicator()),
              pageLoaderBuilder: (_) =>
                  const Center(child: CupertinoActivityIndicator()),
              errorBuilder: (_, error) => Center(child: Text(error.toString())),
            ),
            onPageChanged: _pdfControllerSlider.jumpToPage,
            controller: _pdfController,
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
                  if (pagesCount == null || _thumbnailImageList.isEmpty)
                    return Container();
                  return Center(
                    child: Container(
                      height: 60,
                      width: _thumbnailImageList.length * 37,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.blue,
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
                                    color: Colors.white,
                                    child: _thumbnailImageList.isEmpty ||
                                            _thumbnailImageList.length <= index
                                        ? const CupertinoActivityIndicator()
                                        : Image(
                                            image: MemoryImage(
                                                _thumbnailImageList[index]
                                                    .bytes),
                                          ),
                                  );
                                },
                                itemCount: _thumbnailImageList.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  width: 5,
                                ),
                              ),
                            ),
                          ),
                          if (pagesCount != 1)
                            FlutterSlider(
                              values: [page.toDouble()],
                              max: pagesCount.toDouble(),
                              min: 1,
                              handlerWidth: 45,
                              handlerHeight: 55,
                              handler: FlutterSliderHandler(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: PdfView(
                                  builders:
                                      PdfViewBuilders<DefaultBuilderOptions>(
                                    options: const DefaultBuilderOptions(),
                                    pageBuilder: (
                                      context,
                                      pageImage,
                                      index,
                                      document,
                                    ) =>
                                        PhotoViewGalleryPageOptions(
                                      imageProvider: PdfPageImageProvider(
                                        pageImage,
                                        index,
                                        document.id,
                                      ),
                                      minScale:
                                          PhotoViewComputedScale.contained * 1,
                                      maxScale:
                                          PhotoViewComputedScale.contained * 2,
                                      initialScale:
                                          PhotoViewComputedScale.contained *
                                              1.0,
                                      heroAttributes: PhotoViewHeroAttributes(
                                        tag: '${document.id}-$index',
                                      ),
                                    ),
                                    documentLoaderBuilder: (_) => const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                    pageLoaderBuilder: (_) => const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                    errorBuilder: (_, error) => Center(
                                      child: Text(error.toString()),
                                    ),
                                  ),
                                  controller: _pdfControllerSlider,
                                ),
                              ),
                              trackBar: const FlutterSliderTrackBar(
                                inactiveDisabledTrackBarColor:
                                    Colors.transparent,
                                activeDisabledTrackBarColor: Colors.transparent,
                                inactiveTrackBar: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                activeTrackBar: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                              onDragCompleted:
                                  (handlerIndex, lowerValue, upperValue) {
                                _pdfController.jumpToPage(
                                  (lowerValue as double).toInt(),
                                );
                              },
                              onDragging:
                                  (handlerIndex, lowerValue, upperValue) {
                                _pdfControllerSlider.jumpToPage(
                                  (lowerValue as double).toInt(),
                                );
                              },
                            )
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
    );
  }
}
