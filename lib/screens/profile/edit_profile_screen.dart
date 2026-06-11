import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _fullnameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String _selectedAvatar = 'assets/images/avatars/avatar_1.png'; // Mock asset path
  String? _selectedState;
  String? _selectedCity;

  // Debouncing & validation properties
  Timer? _debounceTimer;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  final Map<String, List<String>> _stateCities = {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru'],
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Saket'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
  };

  final List<String> _avatars = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
  ];

  @override
  void initState() {
    super.initState();
    _usernameCtrl.text = 'carrom_master_99';
    _fullnameCtrl.text = 'Shiva Kumar';
    _dobCtrl.text = '12/04/1998';
    _selectedState = 'Karnataka';
    _selectedCity = 'Bengaluru';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameCtrl.dispose();
    _fullnameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isUsernameAvailable = null;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isCheckingUsername = false;
        // Mock checking: if query is 'taken' or 'admin', say unavailable
        final lower = query.toLowerCase().trim();
        _isUsernameAvailable = lower != 'taken' && lower != 'admin' && lower != 'carrom_master';
      });
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998, 4, 12),
      firstDate: DateTime(1950),
      lastDate: DateTime(2008), // Restricted to >18 years old for legal cash gaming
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: AppColors.bg,
              surface: AppColors.surface,
              onSurface: AppColors.text,
            ),
            dialogBackgroundColor: AppColors.surface2,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isUsernameAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available username.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.teal,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.surface),
            const SizedBox(width: 10),
            Text(
              'Profile updated successfully!',
              style: AppTypography.body.copyWith(color: AppColors.surface, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EDIT PROFILE',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 24),
                _buildFormFields(),
                const SizedBox(height: 28),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.surface,
                  child: const Icon(Icons.person_rounded, size: 50, color: AppColors.purple),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'CHOOSE PRE-MADE AVATAR',
            style: AppTypography.small.copyWith(
              color: AppColors.textSoft,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _avatars.map((av) {
              final isSelected = _selectedAvatar == av;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = av),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.gold : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surface2,
                    child: const Icon(Icons.face_rounded, color: AppColors.textMuted, size: 24),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username Availability check with 1s Debounce
          Text(
            'USERNAME',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _usernameCtrl,
            style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter unique username',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
              suffixIcon: _buildUsernameSuffix(),
            ),
            onChanged: _onUsernameChanged,
            validator: (v) => v == null || v.isEmpty ? 'Username is required' : null,
          ),
          const SizedBox(height: 16),

          // Full Name
          _buildTextField(
            label: 'Full Name (As on KYC ID)',
            controller: _fullnameCtrl,
            hint: 'Your official name',
            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),

          // Date of Birth picker
          Text(
            'DATE OF BIRTH',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _dobCtrl,
            readOnly: true,
            onTap: _selectDate,
            style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'DD/MM/YYYY',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
              suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.gold),
            ),
          ),
          const SizedBox(height: 16),

          // State Dropdown
          Text(
            'STATE',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedState,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
                items: _stateCities.keys.map((st) {
                  return DropdownMenuItem(value: st, child: Text(st));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedState = val;
                      _selectedCity = _stateCities[val]!.first;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // City Dropdown
          Text(
            'CITY',
            style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
                items: (_stateCities[_selectedState] ?? []).map((ct) {
                  return DropdownMenuItem(value: ct, child: Text(ct));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCity = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.purple),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget? _buildUsernameSuffix() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5),
        ),
      );
    }
    if (_isUsernameAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20);
    }
    if (_isUsernameAvailable == false) {
      return const Icon(Icons.cancel_rounded, color: AppColors.red, size: 20);
    }
    return null;
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          'SAVE PROFILE CHANGES',
          style: AppTypography.button.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
