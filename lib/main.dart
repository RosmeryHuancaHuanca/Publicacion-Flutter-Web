import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4), // base vibrante
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Calculadora Flutter Web',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(letterSpacing: .2),
          bodyMedium: TextStyle(letterSpacing: .2),
        ),
      ),
      home: const CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _first;                 // primer operando
  String? _op;                    // operador: + − × ÷
  bool _waitingSecond = false;    // esperando segundo operando
  bool _justCalculated = false;   // se acaba de calcular

  // === LÓGICA ===
  void _inputDigit(String d) {
    setState(() {
      if (_justCalculated) {
        _display = '0';
        _justCalculated = false;
      }
      if (_waitingSecond) {
        _display = '0';
        _waitingSecond = false;
      }
      if (_display == '0') {
        _display = d;
      } else {
        _display += d;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingSecond || _justCalculated) {
        _display = '0';
        _waitingSecond = false;
        _justCalculated = false;
      }
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _clearAll() {
    setState(() {
      _display = '0';
      _first = null;
      _op = null;
      _waitingSecond = false;
      _justCalculated = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_justCalculated) return;
      if (_display.length <= 1 || (_display.length == 2 && _display.startsWith('-'))) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _setOperator(String operator) {
    setState(() {
      if (_op != null && !_waitingSecond && !_justCalculated) {
        _equals();
      }
      _first = double.tryParse(_display) ?? 0.0;
      _op = operator;
      _waitingSecond = true;
      _justCalculated = false;
    });
  }

  void _equals() {
    setState(() {
      if (_op == null || _first == null) {
        _justCalculated = true;
        return;
      }
      final second = double.tryParse(_display) ?? 0.0;
      double result;

      switch (_op) {
        case '+':
          result = _first! + second;
          break;
        case '−':
          result = _first! - second;
          break;
        case '×':
          result = _first! * second;
          break;
        case '÷':
          if (second == 0) {
            _display = 'Error';
            _first = null;
            _op = null;
            _waitingSecond = false;
            _justCalculated = true;
            return;
          }
          result = _first! / second;
          break;
        default:
          return;
      }

      final isInt = result == result.roundToDouble();
      _display = isInt ? result.toInt().toString() : _trimZeros(result.toString());

      _first = null;
      _op = null;
      _waitingSecond = false;
      _justCalculated = true;
    });
  }

  String _trimZeros(String s) {
    // quita ceros y punto final innecesarios
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return s;
  }

  // === UI ===
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final buttons = [
      // fila 1
      _CalcKey(label: 'C',    onTap: _clearAll, tone: KeyTone.function),
      _CalcKey(label: '±',    onTap: _toggleSign, tone: KeyTone.function),
      _CalcKey(label: '⌫',    onTap: _backspace, tone: KeyTone.function),
      _CalcKey(label: '÷',    onTap: () => _setOperator('÷'), tone: KeyTone.op),
      // fila 2
      _CalcKey(label: '7',    onTap: () => _inputDigit('7')),
      _CalcKey(label: '8',    onTap: () => _inputDigit('8')),
      _CalcKey(label: '9',    onTap: () => _inputDigit('9')),
      _CalcKey(label: '×',    onTap: () => _setOperator('×'), tone: KeyTone.op),
      // fila 3
      _CalcKey(label: '4',    onTap: () => _inputDigit('4')),
      _CalcKey(label: '5',    onTap: () => _inputDigit('5')),
      _CalcKey(label: '6',    onTap: () => _inputDigit('6')),
      _CalcKey(label: '−',    onTap: () => _setOperator('−'), tone: KeyTone.op),
      // fila 4
      _CalcKey(label: '1',    onTap: () => _inputDigit('1')),
      _CalcKey(label: '2',    onTap: () => _inputDigit('2')),
      _CalcKey(label: '3',    onTap: () => _inputDigit('3')),
      _CalcKey(label: '+',    onTap: () => _setOperator('+'), tone: KeyTone.op),
      // fila 5
      _CalcKey(label: '0',    onTap: () => _inputDigit('0'), flex: 2),
      _CalcKey(label: '.',    onTap: _inputDecimal),
      _CalcKey(label: '=',    onTap: _equals, tone: KeyTone.equals),
    ];

    return Scaffold(
      // Fondo de temática colorida (degradados superpuestos)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF), // violeta
              Color(0xFF00C2FF), // cian
              Color(0xFFFF7A59), // coral
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // capa radial decorativa
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.2,
                      colors: [
                        Colors.white.withOpacity(0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                      center: Alignment.topRight,
                    ),
                  ),
                ),
              ),
            ),

            // Contenido centrado
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título con badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calculate_rounded, color: Colors.white.withOpacity(.95)),
                          const SizedBox(width: 8),
                          Text(
                            'Calculadora – Flutter Web',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.95),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Display estilo glass
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(.28),
                                  Colors.white.withOpacity(.18),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white.withOpacity(.35), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              _display,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Teclado
                      _KeyboardLayout(
                        buttons: buttons,
                        palettes: _Palettes(
                          // Números
                          normal: const _KeyPalette(
                            from: Color(0xFF313A5C),
                            to: Color(0xFF283149),
                            text: Colors.white,
                          ),
                          // Funciones: C, ±, ⌫
                          function: _KeyPalette(
                            from: const Color(0xFF00C2FF),
                            to: const Color(0xFF2AF598),
                            text: Colors.black.withOpacity(.90),
                          ),
                          // Operadores: ÷ × − +
                          op: const _KeyPalette(
                            from: Color(0xFF6C63FF),
                            to: Color(0xFFB86BFF),
                            text: Colors.white,
                          ),
                          // Igual
                          equals: const _KeyPalette(
                            from: Color(0xFFFF8C42),
                            to: Color(0xFFFF4E7A),
                            text: Colors.white,
                          ),
                          // Borde/hover
                          borderOnLight: Colors.white.withOpacity(.60),
                          shadow: Colors.black.withOpacity(.22),
                        ),
                        surfaceShadow: cs.shadow,
                      ),

                      const SizedBox(height: 10),
                      Opacity(
                        opacity: .85,
                        child: Text(
                          'Tema: vívido • Glass • Gradientes',
                          style: TextStyle(color: Colors.white.withOpacity(.95), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Paletas y Botón con gradiente =======

enum KeyTone { normal, op, equals, function }

class _CalcKey {
  final String label;
  final VoidCallback onTap;
  final int flex;
  final KeyTone tone;
  const _CalcKey({
    required this.label,
    required this.onTap,
    this.flex = 1,
    this.tone = KeyTone.normal,
  });
}

class _KeyPalette {
  final Color from;
  final Color to;
  final Color text;
  const _KeyPalette({required this.from, required this.to, required this.text});
}

class _Palettes {
  final _KeyPalette normal;
  final _KeyPalette op;
  final _KeyPalette equals;
  final _KeyPalette function;
  final Color borderOnLight;
  final Color shadow;
  const _Palettes({
    required this.normal,
    required this.op,
    required this.equals,
    required this.function,
    required this.borderOnLight,
    required this.shadow,
  });

  _KeyPalette forTone(KeyTone t) {
    switch (t) {
      case KeyTone.op:
        return op;
      case KeyTone.equals:
        return equals;
      case KeyTone.function:
        return function;
      case KeyTone.normal:
      default:
        return normal;
    }
  }
}

class _KeyboardLayout extends StatelessWidget {
  final List<_CalcKey> buttons;
  final _Palettes palettes;
  final Color surfaceShadow;
  const _KeyboardLayout({
    required this.buttons,
    required this.palettes,
    required this.surfaceShadow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<_CalcKey>>[];
    for (int i = 0; i < buttons.length; i += 4) {
      rows.add(buttons.sublist(i, (i + 4).clamp(0, buttons.length)));
    }

    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: row
                    .map(
                      (k) => Expanded(
                        flex: k.flex,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _GradientKey(
                            label: k.label,
                            onTap: k.onTap,
                            palette: palettes.forTone(k.tone),
                            borderColor: palettes.borderOnLight,
                            shadowColor: palettes.shadow,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GradientKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final _KeyPalette palette;
  final Color borderColor;
  final Color shadowColor;

  const _GradientKey({
    required this.label,
    required this.onTap,
    required this.palette,
    required this.borderColor,
    required this.shadowColor,
    super.key,
  });

  @override
  State<_GradientKey> createState() => _GradientKeyState();
}

class _GradientKeyState extends State<_GradientKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 70),
      scale: _pressed ? 0.98 : 1.0,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.palette.from, widget.palette.to],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.borderColor.withOpacity(.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.palette.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: .3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
