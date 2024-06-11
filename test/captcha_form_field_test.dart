import 'package:captcha_form_field/captcha_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  late FakeWebViewPlatform platform;
  String publicKey = "6Lc2XV4cAAAAAEx3Z4Z4Z4Z4Z4Z4Z4Z4Z4Z4Z4Z4";
  setUp(() async {
    platform = FakeWebViewPlatform(
        FakeWebViewController(const PlatformWebViewControllerCreationParams()));

    WebViewPlatform.instance = platform;
  });
  // WidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'CaptchaFormField shows [Captcha inválido] when form is submitted',
      (WidgetTester tester) async {
    // Inicialize sua chave para o formulário
    final formKey = GlobalKey<FormState>();

    // Inicialize seu Widget dentro de um formulário
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              CaptchaFormField(
                  onSuccess: (token) {},
                  onResize: (needSolvePluzzes) {},
                  urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                  publicKey: publicKey),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Ação de envio do formulário
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ));

    // Submeta o formulário
    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Verifique se o erro é exibido
    expect(find.text('Captcha inválido'), findsOneWidget);
  });

  testWidgets(
      'CaptchaFormField shows [Captcha expirado] when form is submitted',
      (tester) async {
    // Inicialize sua chave para o formulário
    final formKey = GlobalKey<FormState>();

    // Inicialize seu Widget dentro de um formulário
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              CaptchaFormField(
                onSuccess: (token) {},
                onResize: (needSolvePluzzes) {},
                urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                publicKey: publicKey,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Ação de envio do formulário
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ));

    platform.controller.expireCaptcha();
    // Submeta o formulário

    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Verifique se o erro é exibido
    expect(find.text('Captcha expirado'), findsOneWidget);
  });

  testWidgets('Error disappears after form validation is executed again',
      (tester) async {
    // Inicialize sua chave para o formulário
    final formKey = GlobalKey<FormState>();

    // Inicialize seu Widget dentro de um formulário
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              CaptchaFormField(
                onSuccess: (token) {},
                onResize: (needSolvePluzzes) {},
                urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                publicKey: publicKey,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Ação de envio do formulário
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Captcha inválido'), findsOneWidget);

    //deixar o field valido
    platform.controller.solveCaptcha();

    // Execute a validação do formulário novamente
    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Verifique se o erro desaparece
    expect(find.text('Captcha inválido'), findsNothing);
  });

  //add teste para mostrar erro quando url não é permitida
  testWidgets('Should throw Exception when urlCaptcha is null or empty',
      (tester) async {
    // Teste para null
    expect(
        () => CaptchaFormField(
              onSuccess: (token) {},
              publicKey: publicKey,
            ),
        throwsAssertionError);

    // Teste para vazio
    expect(
        () => CaptchaFormField(
              urlCaptcha: '',
              onSuccess: (token) {},
              publicKey: publicKey,
            ),
        throwsAssertionError);
  });

  //a mensagem de expirado ou invalido deve sumir quando o captcha for resolvido
  testWidgets('Error disappears automatically after captcha is solved',
      (tester) async {
    // Inicialize sua chave para o formulário
    final formKey = GlobalKey<FormState>();

    // Inicialize seu Widget dentro de um formulário
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              CaptchaFormField(
                // formKey: formKey,
                onSuccess: (token) {},
                onResize: (needSolvePluzzes) {},
                urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                publicKey: publicKey,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Ação de envio do formulário
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Captcha inválido'), findsOneWidget);

    //deixar o field valido
    platform.controller.solveCaptcha();

    await tester.pump();

    // Verifique se o erro desaparece
    expect(find.text('Captcha inválido'), findsNothing);
  });

  testWidgets('When Captcha channel is called should reset expired Message',
      (tester) async {
    final formKey = GlobalKey<FormState>();

    // Inicialize seu Widget dentro de um formulário
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              CaptchaFormField(
                onSuccess: (token) {},
                onResize: (needSolvePluzzes) {},
                urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                publicKey: publicKey,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Ação de envio do formulário
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Captcha inválido'), findsOneWidget);

    //deixar o field valido
    platform.controller.expireCaptcha();
    await tester.pump();

    // Verifique se o erro desaparece
    expect(find.text('Captcha expirado'), findsOneWidget);
    platform.controller.solveCaptcha();

    await tester.pump();

    // Verifique se o erro desaparece
    expect(find.text('Captcha inválido'), findsNothing);
  });

  testWidgets(
    'When solve captcha and it expired then is solved again, should not appear message [Captcha expirado]',
    (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                CaptchaFormField(
                  onSuccess: (token) {},
                  onResize: (needSolvePluzzes) {},
                  urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                  publicKey: publicKey,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Ação de envio do formulário
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Captcha inválido'), findsOneWidget);

      // Deixar o field válido
      platform.controller.expireCaptcha();
      await tester.pump();

      // Verifique se o erro desaparece
      expect(find.text('Captcha expirado'), findsOneWidget);
      platform.controller.solveCaptcha();

      await tester.pump();

      // Verifique se o erro desaparece
      expect(find.text('Captcha expirado'), findsNothing);
    },
  );

  testWidgets(
      'When invalidate [captchaController] should call webviewController reload method',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = CaptchaFormController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  CaptchaFormField(
                    controller: controller,
                    onSuccess: (token) {},
                    onResize: (needSolvePluzzes) {},
                    urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                    publicKey: publicKey,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.invalidate();
              },
              child: const Text('Invalidate'),
            ),
          ],
        ),
      ),
    ));

    expect(platform.controller.reloadCalled, false);

    await tester.tap(find.text('Invalidate'));
    await tester.pump();

    expect(platform.controller.reloadCalled, true);
  });

  testWidgets('''When calling invalidate after solving the captcha, 
  it should display [Captcha inválido] after submitting it again''',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = CaptchaFormController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  CaptchaFormField(
                    controller: controller,
                    onSuccess: (token) {},
                    onResize: (needSolvePluzzes) {},
                    urlCaptcha: 'http://localhost:5501/recaptcha-app.html',
                    publicKey: publicKey,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.invalidate();
              },
              child: const Text('Invalidate'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Ação de envio do formulário
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    ));

    //deixar o field valido
    platform.controller.solveCaptcha();

    await tester.pump();

    // Verifique se o erro desaparece
    expect(find.text('Captcha inválido'), findsNothing);

    await tester.tap(find.text('Invalidate'));
    await tester.pump();

    expect(platform.controller.reloadCalled, true);

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Captcha inválido'), findsOneWidget);
  });
}

class FakeWebViewPlatform extends WebViewPlatform {
  final FakeWebViewController controller;

  FakeWebViewPlatform(this.controller);

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return controller;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakeWebViewWidget(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return FakeCookieManager(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return FakeNavigationDelegate(params);
  }
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params) : super.implementation();

  final List<JavaScriptChannelParams> _channels = [];
  bool reloadCalled = false;

  void expireCaptcha() {
    for (final channel in _channels) {
      if (channel.name == 'OnExpired') {
        channel.onMessageReceived(const JavaScriptMessage(
            message:
                '{"showPluzze":true,"captchaHeight":150,"captchaWidth":300}'));
      }
    }
  }

  void solveCaptcha() {
    for (final channel in _channels) {
      if (channel.name == 'OnSuccess') {
        channel.onMessageReceived(const JavaScriptMessage(
            message: 'some thing that looks like a token'));
      }
    }
  }

  bool clearLocalStorageCalled = false;
  @override
  Future<void> clearLocalStorage() async {
    clearLocalStorageCalled = true;
  }

  @override
  Future<void> setOnConsoleMessage(
      void Function(JavaScriptConsoleMessage consoleMessage)
          onConsoleMessage) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> addJavaScriptChannel(
      JavaScriptChannelParams javaScriptChannelParams) async {
    _channels.add(javaScriptChannelParams);
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<String?> currentUrl() async {
    return 'http://localhost:5501/recaptcha-app.html';
  }

  @override
  Future<void> reload() async {
    reloadCalled = true;
  }
}

class FakeCookieManager extends PlatformWebViewCookieManager {
  FakeCookieManager(super.params) : super.implementation();
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FakeNavigationDelegate extends PlatformNavigationDelegate {
  FakeNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}
}
