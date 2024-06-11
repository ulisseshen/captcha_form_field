
# captcha_form_field
---

`captcha_form_field` é um pacote Flutter que integra o Google reCAPTCHA v2 em suas aplicações Flutter, proporcionando segurança aprimorada para prevenir abusos automatizados.

## Funcionalidades

- Integração fácil do Google reCAPTCHA v2
- Aparência do CAPTCHA personalizável
- Validação simples e tratamento de erros
- Suporte para recarregamento do CAPTCHA

## Instalação

Adicione `captcha_form_field` ao seu `pubspec.yaml`:

```yaml
dependencies:
  captcha_form_field: ^1.0.0
```

Em seguida, execute `flutter pub get` para instalar o pacote.

## Uso

### Exemplo Básico

```dart
import 'package:flutter/material.dart';
import 'package:captcha_form_field/captcha_form_field.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Exemplo de Captcha Form Field')),
        body: MyForm(),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isCaptchaValid = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CaptchaFormField(
            publicKey: 'sua-chave-publica',
            urlCaptcha: 'sua-url-captcha',
            onSuccess: (token) {
              setState(() {
                _isCaptchaValid = true;
              });
            },
          ),
          ElevatedButton(
            onPressed: _isCaptchaValid ? _submitForm : null,
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Processar dados
    }
  }
}
```

### Personalização

Você pode personalizar o campo CAPTCHA especificando várias propriedades:

```dart
CaptchaFormField(
  publicKey: 'sua-chave-publica',
  urlCaptcha: 'sua-url-captcha',
  onSuccess: (token) {
    // Tratar sucesso
  },
  onResize: (needSolvePluzzes) {
    // Tratar redimensionamento se necessário
  },
  onExpired: () {
    // Tratar expiração
  },
  controller: CaptchaFormController(),
)
```

### Configuração

Para usar o Google reCAPTCHA, obtenha sua chave do site no [console de administração do Google reCAPTCHA](https://www.google.com/recaptcha/admin). A `urlCaptcha` deve apontar para uma URL válida que serve o CAPTCHA.

**Nota:** Você precisa hospedar o arquivo HTML [recaptcha-app.html](`assets/recaptcha-app.html`) que está na pasta assets no seu próprio servidor. Instruções para configurar o servidor estão além do escopo deste projeto.

## Contribuindo

Contribuições são bem-vindas! Por favor, abra uma issue ou envie um pull request.

## Licença

Este projeto é licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Autor

Desenvolvido por [Ulisses Hen](https://github.com/ulisseshen).

---