library captcha_form_field;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract class ICaptchaFormFieldController {
  /// Pode ser usado para forçar o reload do captcha
  /// quando o usuário já resolveu o catpcha e o mesmo
  /// já foi validado no servidor.
  void invalidate();
}

class CaptchaFormController implements ICaptchaFormFieldController {
  @override
  void invalidate() {
    if (_onInvalidate != null) {
      _onInvalidate!();
    }
  }

  //callback quando invalidate for chamado
  void Function()? _onInvalidate;

  void _listenInvalidate(void Function()? callback) {
    _onInvalidate = callback;
  }
}

class CaptchaFormField extends StatefulWidget {
  final Function(String token) onSuccess;
  final Function(bool needSolvePluzzes)? onResize;
  final Function()? onExpired;
  final String urlCaptcha;
  final CaptchaFormController? controller;

  CaptchaFormField({
    super.key,
    this.controller,
    required this.onSuccess,
    this.onResize,
    this.onExpired,
    String? urlCaptcha,
  }) : urlCaptcha = urlCaptcha ??
            const String.fromEnvironment(
              'urlCaptcha',
              defaultValue: '',
            ) {
    assert(this.urlCaptcha != '',
        'O parâmetro urlCaptcha não pode ser nulo ou vazio. Certifique-se de fornecer uma URL válida para o captcha ou configurar a variável de ambiente "urlCaptcha".');
  }

  @override
  State<StatefulWidget> createState() {
    return CaptchaFormFieldState();
  }
}

class CaptchaFormFieldState extends State<CaptchaFormField> {
  @override
  initState() {
    super.initState();
    widget.controller?._listenInvalidate(() {
      _controller?.reload();
    });
    _setupWebviewController(context);
  }

  double _captchaHeight = 90;
  WebViewController? _controller;
  WebViewWidget? _webview;
  String? _token;
  bool _expired = false;
  GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    _webview ??= WebViewWidget(
      controller: _controller!,
    );

    return FormField(
      key: formKey,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: _captchaHeight, end: _captchaHeight),
              duration: const Duration(
                  milliseconds: 400), // Defina a duração da animação
              builder: (BuildContext context, double value, Widget? child) {
                return SizedBox(
                  height: value,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      child: _webview,
                    ),
                  ),
                );
              },
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        );
      },
      validator: (_) {
        //TODO precisa testar essa validação
        if (_expired) {
          // _expired = false;
          return 'Captcha expirado';
        }
        return _token == null ? 'Captcha inválido' : null;
      },
    );
  }

  void _setupWebviewController(BuildContext context) {
    _controller ??= WebViewController()
      ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Captcha', //TODO renomear para [OnSuccess]
          onMessageReceived: (JavaScriptMessage message) {
        widget.onSuccess(message.message);
        _token = message.message;

        _validateCaptcha();

        formKey.currentState?.validate();
      })
      ..addJavaScriptChannel('OnShowPluzze', onMessageReceived: (message) {
        _onShowPluzze(message, context);

        formKey.currentState?.validate();
      })
      ..addJavaScriptChannel('OnExpired', onMessageReceived: (_) {
        _expired = true;
        if (widget.onExpired != null) {
          widget.onExpired!();
        }

        formKey.currentState?.validate();
      })
      ..loadRequest(Uri.parse(widget.urlCaptcha));

    //evitar que se abra outra url
    _controller!.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (NavigationRequest navigationRequest) {
        if (navigationRequest.url == widget.urlCaptcha ||
            navigationRequest.url.contains('recaptcha') ||
            navigationRequest.url.contains('about:blank')) {
          return NavigationDecision.navigate;
        }
        return NavigationDecision.prevent;
      },
    ));
  }

  void _validateCaptcha() {
    _expired = false;
  }

  void _onShowPluzze(
      JavaScriptMessage onMessageReceived, BuildContext context) {
    final jsonResult = json.decode(onMessageReceived.message);

    final needSolvePluzzes = jsonResult['showPluzze'] as bool;

    final captchaHeight =
        double.tryParse(jsonResult['captchaHeight'].toString()) ??
            MediaQuery.of(context).size.height;

    if (needSolvePluzzes) {
      setState(() {
        _captchaHeight = captchaHeight == 150
            ? MediaQuery.of(context).size.height
            : captchaHeight + 5;
      });
    } else {
      if (_captchaHeight != 90) {
        setState(() {
          _captchaHeight = 90;
        });
      }
    }
  }
}
