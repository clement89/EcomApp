import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

typedef DoubleClickAnimationListener = void Function();

class ImageZoom extends StatefulWidget {
  static String routeName = "/image_zoom";
  final List<String> imageUrls;
  ImageZoom({
    this.imageUrls,
  });
  @override
  _ImageZoomState createState() => _ImageZoomState();
}

class _ImageZoomState extends State<ImageZoom> with TickerProviderStateMixin {
  List<String> images;
  //pageview
  int currentIndex = 0;
  PageController _controller = PageController(initialPage: 0);

  //extended image double tap initilaisations.
  AnimationController _doubleClickAnimationController;
  Animation<double> _doubleClickAnimation;
  DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];

  void moveToPage(int index) {
    _controller.jumpToPage(index);
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Image Zoom");
    super.initState();
    images = widget?.imageUrls;
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _doubleClickAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerBar(title: "", context: context),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  child: ExtendedImageGesturePageView.builder(
                    itemBuilder: (_, index) {
                      return ExtendedImage.network(
                        images[index],
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        cache: true,
                        loadStateChanged: (currentState) {
                          if (currentState.extendedImageLoadState ==
                                  LoadState.loading ||
                              currentState.extendedImageLoadState ==
                                  LoadState.failed) {
                            return Image.asset(
                              "assets/images/placeholder.webp",
                              fit: BoxFit.contain,
                            );
                          }
                        },
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                            minScale: 0.9,
                            animationMinScale: 0.7,
                            maxScale: 3.0,
                            animationMaxScale: 3.5,
                            speed: 1.0,
                            inertialSpeed: 100.0,
                            initialScale: 1.0,
                            inPageView: false,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                        onDoubleTap: (ExtendedImageGestureState state) {
                          ///you can use define pointerDownPosition as you can,
                          ///default value is double tap pointer down postion.
                          final Offset pointerDownPosition =
                              state.pointerDownPosition;
                          final double begin = state.gestureDetails.totalScale;
                          double end;

                          //remove old
                          _doubleClickAnimation
                              ?.removeListener(_doubleClickAnimationListener);

                          //stop pre
                          _doubleClickAnimationController.stop();

                          //reset to use
                          _doubleClickAnimationController.reset();

                          if (begin == doubleTapScales[0]) {
                            end = doubleTapScales[1];
                          } else {
                            end = doubleTapScales[0];
                          }

                          _doubleClickAnimationListener = () {
                            //logNesto(_animation.value);
                            state.handleDoubleTap(
                                scale: _doubleClickAnimation.value,
                                doubleTapPosition: pointerDownPosition);
                          };
                          _doubleClickAnimation =
                              _doubleClickAnimationController
                                  .drive(Tween<double>(begin: begin, end: end));

                          _doubleClickAnimation
                              .addListener(_doubleClickAnimationListener);

                          _doubleClickAnimationController.forward();
                        },
                      );
                    },
                    itemCount: images.length,
                    onPageChanged: (int page) {
                      setState(() {
                        // currentIndex = page % images.length;
                        currentIndex = page;
                      });
                    },
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
              Visibility(
                maintainSize: false,
                visible: images.length > 1,
                child: Container(
                  height: 80,
                  color: Colors.white,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          moveToPage(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                            bottom: BorderSide(
                                width: 5.0,
                                color: currentIndex == index
                                    ? Colors.green
                                    : Colors.transparent),
                          )),
                          width: 50,
                          child: ExtendedImage.network(
                            images[index],
                            fit: BoxFit.fill,
                            cache: true,
                            clearMemoryCacheWhenDispose: true,
                            clearMemoryCacheIfFailed: true,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, index) {
                      return SizedBox(
                        width: 5,
                      );
                    },
                    itemCount: images.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
