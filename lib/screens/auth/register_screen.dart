import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, TextInputFormatter, FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:provider/provider.dart';

import 'package:biowayapp/services/auth_service.dart';
import 'package:biowayapp/services/config_service.dart';
import 'package:biowayapp/theme/app_colors.dart';
import 'package:biowayapp/widgets/user_type_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  final int _totalPages = 3;

  // Form keys para cada paso
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  // Controladores de los campos
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _numExtController = TextEditingController();
  final _cpController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _colonyController = TextEditingController();

  String? _selectedUserType;
  bool _acceptedPrivacy = false;
  bool _isLoading = false;

  // Variables para mostrar/ocultar contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _numExtController.dispose();
    _cpController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _colonyController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddressFromCP(String cp) async {
    if (cp.isEmpty) return;
    try {
      final jsonString = await rootBundle.loadString('assets/cp_data.json');
      final List<dynamic> data = jsonDecode(jsonString);
      final record = data.firstWhere(
            (item) => item['cp'].toString() == cp,
        orElse: () => null,
      );
      if (record != null) {
        setState(() {
          _stateController.text = record['estado'] ?? '';
          _cityController.text = record['municipio'] ?? '';
          _colonyController.text = record['colonia'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error fetching CP data: $e");
    }
  }

  Future<void> _register() async {
    if (!_formKeyStep1.currentState!.validate() ||
        !_formKeyStep2.currentState!.validate() ||
        !_formKeyStep3.currentState!.validate()) {
      return;
    }

    if (_selectedUserType == null) {
      _showErrorSnackBar('Por favor seleccione un tipo de usuario');
      return;
    }

    if (!_acceptedPrivacy) {
      _showErrorSnackBar('Debe aceptar el aviso de privacidad');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        address: _addressController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        isBrindador: _selectedUserType == "brindador",
        numExt: _numExtController.text.trim(),
        colonia: _colonyController.text.trim(),
        cp: _cpController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20,
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == 0 && _formKeyStep1.currentState!.validate()) {
      _animateToNextPage();
    } else if (_currentPage == 1 && _formKeyStep2.currentState!.validate()) {
      _animateToNextPage();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _animateToNextPage() {
    _animationController.reverse().then((_) {
      _pageController
          .nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        _animationController.forward();
      });
    });
  }

  /// Campo de texto personalizado con parámetros adicionales
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    bool? customObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: customObscure ?? isPassword,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          bool isActive = index == _currentPage;
          bool isPast = index < _currentPage;
          return Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isPast ? AppColors.primary : Colors.grey[200],
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.grey[300]!,
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive || isPast ? Colors.white : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < _totalPages - 1)
                Container(
                  width: 40,
                  height: 2,
                  color: isPast ? AppColors.primary : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1Form() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        children: [
          // Nombre de usuario limitado a 10 caracteres
          _buildAnimatedTextField(
            controller: _fullNameController,
            hintText: 'Nombre completo',
            icon: Icons.person_outline,
            validator: (value) =>
            value?.isEmpty ?? true ? 'Este campo es requerido' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
          ),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _emailController,
            hintText: 'Correo electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Este campo es requerido';
              if (!value!.contains('@')) return 'Ingrese un correo válido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Contraseña limitada a 10 caracteres con botón para mostrar/ocultar
          _buildAnimatedTextField(
            controller: _passwordController,
            hintText: 'Contraseña',
            icon: Icons.lock_outline,
            isPassword: true,
            customObscure: _obscurePassword,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Este campo es requerido';
              if (value!.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
              return null;
            },
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Confirmar contraseña con verificación de coincidencia
          _buildAnimatedTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirmar Contraseña',
            icon: Icons.lock_outline,
            isPassword: true,
            customObscure: _obscureConfirmPassword,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Este campo es requerido';
              if (value != _passwordController.text)
                return 'Las contraseñas no coinciden';
              return null;
            },
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Form() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildAnimatedTextField(
                  controller: _addressController,
                  hintText: 'Calle',
                  icon: Icons.location_on_outlined,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Este campo es requerido' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _numExtController,
                  hintText: 'Núm. Ext',
                  icon: Icons.numbers,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Requerido' : null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCPField(),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _stateController,
            hintText: 'Estado',
            icon: Icons.map,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _cityController,
            hintText: 'Municipio',
            icon: Icons.location_city,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _colonyController,
            hintText: 'Colonia',
            icon: Icons.home,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Form() {
    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección compacta para selección de tipo de usuario
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Tipo de Usuario',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                UserTypeSelector(
                  selected: _selectedUserType,
                  onChanged: (value) => setState(() => _selectedUserType = value),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sección compacta para términos y condiciones
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Términos y Condiciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPrivacyCheckbox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCPField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _cpController,
              decoration: InputDecoration(
                hintText: 'Código Postal',
                prefixIcon: Icon(Icons.location_on, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Este campo es requerido' : null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primary),
            onPressed: () => _fetchAddressFromCP(_cpController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: _acceptedPrivacy,
            onChanged: (value) =>
                setState(() => _acceptedPrivacy = value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => ConfigService.openPrivacyPolicy(),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                children: [
                  const TextSpan(text: 'He leído, entendido y acordado el presente '),
                  TextSpan(
                    text: 'aviso de privacidad',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' que BIOWAY ha puesto en mi conocimiento.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentPage == 0) {
      return Center(
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Siguiente', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      );
    } else if (_currentPage < _totalPages - 1) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previousPage,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Anterior', style: TextStyle(fontSize: 16, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    } else {
      if (_acceptedPrivacy) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Atrás', style: TextStyle(fontSize: 16, color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Registrarse', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        );
      } else {
        return Center(
          child: OutlinedButton(
            onPressed: _previousPage,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Atrás', style: TextStyle(fontSize: 16, color: AppColors.primary)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El contenedor blanco no se redimensiona al abrir el teclado.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo con gradiente (usando los colores del login)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Onda decorativa
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Encabezado centrado con espacio reservado a la izquierda y derecha.
                        Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: AppColors.primary),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Registro',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        _buildStepIndicator(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (index) => setState(() => _currentPage = index),
                            children: [
                              _buildStep1Form(),
                              _buildStep2Form(),
                              _buildStep3Form(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNavigationButtons(),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text(
                            '¿Ya tienes cuenta? Inicia sesión',
                            style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 60,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
