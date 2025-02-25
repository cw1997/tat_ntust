import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/file/file_download.dart';
import 'package:flutter_app/src/util/open_utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewPage extends StatefulWidget {
  final Uri url;
  final String title;
  final bool openWithExternalWebView;
  final Function(Uri)? onWebViewDownload;
  final Function(InAppWebViewController) loadDone;

  const InAppWebViewPage({
    required this.title,
    required this.url,
    this.openWithExternalWebView = false,
    this.onWebViewDownload,
    required this.loadDone,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.instance.cookiesManager;
  InAppWebViewController? webView;
  Uri url = Uri();
  double progress = 0;
  int onLoadStopTime = -1;
  Uri? lastLoadUri;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (onLoadStopTime >= 1) {
      webView!.goBack();
      onLoadStopTime -= 2;
      return true;
    }
    return false;
  }

  bool firstLoad = false;

  Future<bool> setCookies() async {
    if (!firstLoad) return true;
    firstLoad = false;
    final cookies = await cookieJar.loadForRequest(widget.url);
    await cookieManager.deleteAllCookies();
    var existCookies = await cookieManager.getCookies(url: widget.url);
    final cookiesName = existCookies.map((e) => e.name).toList();
    for (var cookie in cookies) {
      if (!cookiesName.contains(cookie.name)) {
        cookiesName.add(cookie.name);
        await cookieManager.setCookie(
          url: widget.url,
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          path: cookie.path!,
          maxAge: cookie.maxAge,
          isSecure: cookie.secure,
          isHttpOnly: cookie.httpOnly,
        );
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          SizedBox(
            width: 50,
            child: InkWell(
              onTap: () async {
                if (webView != null) {
                  await webView!.goBack();
                }
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 50,
            child: InkWell(
              onTap: () async {
                if (webView != null) {
                  await webView!.goForward();
                }
              },
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 50,
            child: InkWell(
              onTap: () async {
                if (webView != null) {
                  await webView!.reload();
                }
              },
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          if (widget.openWithExternalWebView)
            SizedBox(
              width: 50,
              child: InkWell(
                onTap: () async {
                  OpenUtils.launchURL(url.toString());
                },
                child: const Icon(Icons.open_in_new, color: Colors.white),
              ),
            ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: setCookies(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    child: progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ),
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: widget.url),
                      initialOptions: InAppWebViewGroupOptions(
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true, //android 12 keyboard
                        ),
                        crossPlatform: InAppWebViewOptions(
                          useOnDownloadStart: true,
                        ),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webView = controller;
                      },
                      onLoadStart:
                          (InAppWebViewController controller, Uri? url) {
                        setState(() {
                          if (lastLoadUri != url) {
                            onLoadStopTime++;
                          }
                          lastLoadUri = url;
                          this.url = url!;
                        });
                      },
                      onLoadStop:
                          (InAppWebViewController controller, Uri? url) async {
                        widget.loadDone(controller);
                        setState(
                          () {
                            this.url = url!;
                          },
                        );
                      },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {
                        setState(
                          () {
                            this.progress = progress / 100;
                          },
                        );
                      },
                      onDownloadStartRequest:
                          (InAppWebViewController controller,
                              DownloadStartRequest downloadStartRequest) {
                        var url = downloadStartRequest.url;
                        Log.d("WebView download ${url.toString()}");
                        if (widget.onWebViewDownload != null) {
                          widget.onWebViewDownload!(url);
                        } else {
                          String dirName = "WebView";
                          FileDownload.download(
                              context, url.toString(), dirName);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
