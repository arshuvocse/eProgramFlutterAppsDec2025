import 'package:flutter/material.dart';

class ProviderEnrollmentView extends StatefulWidget {
  const ProviderEnrollmentView({super.key});

  @override
  State<ProviderEnrollmentView> createState() => _ProviderEnrollmentViewState();
}

class _ProviderEnrollmentViewState extends State<ProviderEnrollmentView> {
  static const _brand = Color(0xFF008080);
  static const _brandDark = Color(0xFF0A2540);
  static const _pageBg = Color(0xFFF3F6FA);
  static const _fieldFill = Color(0xFFF7F9FC);

  DateTime? _basicTrainingDate;
  DateTime? _dob;
  DateTime? _marriageDate;

  String? _project;
  String? _groupType;
  String? _doctorType;
  String? _tfos;
  String? _trainingRequired;
  String? _ogbs;
  String? _gender;
  String? _married;
  String? _academic;
  String? _professional;
  String? _division;
  String? _district;
  String? _thana;
  String? _locationArea;

  static const _projectOptions = [
    'Project A',
    'Project B',
    'Project C',
  ];

  static const _groupTypeOptions = [
    'Clinic',
    'Hospital',
    'NGO',
    'Other',
  ];

  static const _doctorTypeOptions = [
    'IND',
    'INS',
  ];

  static const _yesNoOptions = [
    'Yes',
    'No',
  ];

  static const _maritalOptions = [
    'Married',
    'Unmarried',
  ];

  static const _genderOptions = [
    'Male',
    'Female',
    'Other',
  ];

  static const _academicOptions = [
    'MBBS',
    'BSc',
    'Diploma',
    'Other',
  ];

  static const _professionalOptions = [
    'FCPS',
    'MD',
    'MS',
    'Other',
  ];

  static const _divisionOptions = [
    'Dhaka',
    'Chattogram',
    'Khulna',
    'Rajshahi',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  static const _districtOptions = [
    'Dhaka',
    'Gazipur',
    'Narayanganj',
    'Chattogram',
    'Khulna',
  ];

  static const _thanaOptions = [
    'Dhanmondi',
    'Mirpur',
    'Kotwali',
    'Savar',
  ];

  static const _locationAreaOptions = [
    'Urban',
    'Semi-Urban',
    'Rural',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: const Text(
          'Provider Enrollment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              _buildSectionCard(
                title: 'Enrollment Details',
                icon: Icons.assignment_outlined,
                children: [
                  _buildDateField(
                    label: 'Basic Training Date',
                    required: true,
                    value: _basicTrainingDate,
                    onTap: () => _pickDate(
                      context,
                      initial: _basicTrainingDate,
                      onPicked: (value) => setState(() => _basicTrainingDate = value),
                    ),
                  ),
                  _buildDropdownField(
                    label: 'Project/Program Name',
                    required: true,
                    value: _project,
                    options: _projectOptions,
                    hint: 'Select Project/Program',
                    onChanged: (value) => setState(() => _project = value),
                  ),
                  _buildTextField(
                    label: 'Provider Name',
                    required: true,
                    hint: 'Enter provider name',
                    textCapitalization: TextCapitalization.words,
                  ),
                  _buildTextField(
                    label: 'Mobile No',
                    required: true,
                    hint: '11-digit BD number',
                    keyboardType: TextInputType.phone,
                  ),
                  _buildDropdownField(
                    label: 'Group Type',
                    required: true,
                    value: _groupType,
                    options: _groupTypeOptions,
                    hint: 'Select Group',
                    onChanged: (value) => setState(() => _groupType = value),
                  ),
                  _buildTextField(
                    label: 'Address',
                    hint: 'Enter address',
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  _buildTextField(
                    label: 'Trade License',
                    hint: 'Enter trade license no.',
                  ),
                  _buildTextField(
                    label: 'NID',
                    hint: 'Enter NID no.',
                    keyboardType: TextInputType.number,
                  ),
                  _buildDropdownField(
                    label: 'Doctor Type',
                    value: _doctorType,
                    options: _doctorTypeOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _doctorType = value),
                  ),
                  _buildDropdownField(
                    label: 'Training From Other Sources (TFOS)?',
                    value: _tfos,
                    options: _yesNoOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _tfos = value),
                  ),
                  _buildDropdownField(
                    label: 'Is Training Required?',
                    value: _trainingRequired,
                    options: _yesNoOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _trainingRequired = value),
                  ),
                  _buildDropdownField(
                    label: 'Obstetrical and Gynecological Society of Bangladesh (OGBS)?',
                    value: _ogbs,
                    options: _yesNoOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _ogbs = value),
                  ),
                  _buildTextField(
                    label: 'Focal Person Name',
                    hint: 'Enter focal person name',
                    textCapitalization: TextCapitalization.words,
                  ),
                  _buildTextField(
                    label: 'Focal Person Mobile No.',
                    hint: '11-digit BD number',
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    label: 'Institute / NGO Address',
                    required: true,
                    hint: 'Enter institute / NGO address',
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  _buildTextField(
                    label: 'Institute Focal Person Name',
                    hint: 'Enter focal person name',
                    textCapitalization: TextCapitalization.words,
                  ),
                  _buildTextField(
                    label: 'Institute Focal Person Mobile No.',
                    hint: '11-digit BD number',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                children: [
                  _buildDropdownField(
                    label: 'Gender',
                    required: true,
                    value: _gender,
                    options: _genderOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  _buildDateField(
                    label: 'Date of Birth',
                    required: true,
                    value: _dob,
                    onTap: () => _pickDate(
                      context,
                      initial: _dob,
                      onPicked: (value) => setState(() => _dob = value),
                    ),
                  ),
                  _buildTextField(
                    label: 'Email',
                    hint: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildDropdownField(
                    label: 'Marital Status',
                    value: _married,
                    options: _maritalOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() {
                      _married = value;
                      if (_married != 'Married') {
                        _marriageDate = null;
                      }
                    }),
                  ),
                  _buildDateField(
                    label: 'Date of Marriage',
                    value: _marriageDate,
                    enabled: _married == 'Married',
                    onTap: _married == 'Married'
                        ? () => _pickDate(
                              context,
                              initial: _marriageDate,
                              onPicked: (value) => setState(() => _marriageDate = value),
                            )
                        : null,
                  ),
                  _buildDropdownField(
                    label: 'Academic Qualification',
                    required: true,
                    value: _academic,
                    options: _academicOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _academic = value),
                  ),
                  _buildDropdownField(
                    label: 'Professional Qualification',
                    required: true,
                    value: _professional,
                    options: _professionalOptions,
                    hint: 'Select',
                    onChanged: (value) => setState(() => _professional = value),
                  ),
                  
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Market Information',
                icon: Icons.map_outlined,
                children: [
                  _buildDropdownField(
                    label: 'Location / Area',
                    required: true,
                    value: _locationArea,
                    options: _locationAreaOptions,
                    hint: 'Select location / area',
                    onChanged: (value) => setState(() => _locationArea = value),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'GEO Information',
                icon: Icons.map_outlined,
                children: [
                  _buildDropdownField(
                    label: 'Division',
                    required: true,
                    value: _division,
                    options: _divisionOptions,
                    hint: 'Select Division',
                    onChanged: (value) => setState(() => _division = value),
                  ),
                  _buildDropdownField(
                    label: 'District',
                    required: true,
                    value: _district,
                    options: _districtOptions,
                    hint: 'Select District',
                    onChanged: (value) => setState(() => _district = value),
                  ),
                  _buildDropdownField(
                    label: 'Upazila / Thana',
                    required: true,
                    value: _thana,
                    options: _thanaOptions,
                    hint: 'Select Upazila/Thana',
                    onChanged: (value) => setState(() => _thana = value),
                  ),
                  _buildTextField(
                    label: 'Union / UCC / UMU',
                    hint: 'Enter Union / UCC / UMU',
                    textCapitalization: TextCapitalization.words,
                  ),
                  _buildTextField(
                    label: 'Ward / Market',
                    hint: 'Enter ward / market',
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Remark',
                icon: Icons.sticky_note_2_outlined,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Remark',
                        hint: 'Write any additional notes (optional)',
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'This note will be saved with the provider record.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showSnack(context, 'Draft action is not connected yet.'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _brand, width: 1.6),
                    foregroundColor: _brand,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'SAVE DRAFT',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSnack(context, 'Submit action is not connected yet.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final spaced = _withSpacing(children);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _brand, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _brandDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...spaced,
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items, {double gap = 12}) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(SizedBox(height: gap));
      }
    }
    return out;
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required String hint,
    String? value,
    bool required = false,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(label: label, required: required),
      hint: Text(
        hint,
        style: const TextStyle(color: Colors.black38),
      ),
      items: options
          .map(
            (opt) => DropdownMenuItem<String>(
              value: opt,
              child: Text(opt),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback? onTap,
    bool required = false,
    bool enabled = true,
  }) {
    final active = enabled && onTap != null;
    return InkWell(
      onTap: active ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: label,
          required: required,
          suffixIcon: Icon(Icons.calendar_month_outlined, color: _brand.withValues(alpha: 0.85)),
        ),
        child: Text(
          value != null ? _formatDate(value) : '-----',
          style: TextStyle(
            fontSize: 16,
            color: active ? Colors.black87 : Colors.black38,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: _inputDecoration(
        label: label,
        required: required,
        hintText: hint,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    bool required = false,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      label: _label(label, required),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: _fieldFill,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blueGrey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brand, width: 1.4),
      ),
    );
  }

  Widget _label(String text, bool required) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required ValueChanged<DateTime> onPicked,
    DateTime? initial,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$y-$m-$d';
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
