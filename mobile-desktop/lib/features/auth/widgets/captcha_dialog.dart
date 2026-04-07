import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CaptchaDialog extends StatefulWidget {
  final String siteKey;

  const CaptchaDialog({
    Key? key,

    this.siteKey = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI',
  }) : super(key: key);

  @override
  State<CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    

    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://www.google.com/recaptcha/api.js" async defer></script>
        <style>
          body, html {
            height: 100%;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: #2A2E39;
          }
        </style>
        <script>
          function captchaCallback(response) {
            
            CaptchaChannel.postMessage(response);
          }
        </script>
      </head>
      <body>
        <!-- The reCAPTCHA widget -->
        <div class="g-recaptcha" 
             data-sitekey="${widget.siteKey}" 
             data-callback="captchaCallback"
             data-theme="dark">
        </div>
      </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF2A2E39))
      ..addJavaScriptChannel(
        'CaptchaChannel',
        onMessageReceived: (JavaScriptMessage message) {

          Navigator.of(context).pop(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )

      ..loadHtmlString(htmlContent, baseUrl: 'http://localhost');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2A2E39),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 350,
        width: 350,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [

            WebViewWidget(controller: _controller),
            

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
              
            
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}