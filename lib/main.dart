import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class AppColors {
  static const Color colorPrimary = Color(0xFF1565C0); // Airline Blue
  static const Color colorOnPrimary = Color(0xFFFFFFFF);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Estimator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorPrimary,
        ).copyWith(
          primary: AppColors.colorPrimary,
          onPrimary: AppColors.colorOnPrimary,
        ),
      ),
      home: const MyHomePage(title: 'Excess Baggage Estimator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Navigation menu index (0 = Home, 1 = About)
  int selectedIndex = 0;

  // Controllers for the 2 numeric TextFields
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  // Variable for the non-textfield widget (Dropdown)
  String selectedClass = 'Economy';

  // Output and error message variables
  String errorMessage = '';
  String excessWeightResult = '';
  String excessChargeResult = '';
  String totalPayableResult = '';

  // TODO: Replace with your actual GitHub repository URL
  final String githubUrl = 'https://github.com/2025423452-coder/excess_baggage_estimator.git';

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  void calculateFee() {
    // tryParse() returns null instead of throwing an error
    final double? weight = double.tryParse(weightController.text.trim());
    final double? rate = double.tryParse(rateController.text.trim());

    // Input validation (Error message)
    if (weight == null || rate == null) {
      setState(() {
        errorMessage = 'Error: Please enter valid numbers for weight and rate.';
        excessWeightResult = '';
        excessChargeResult = '';
        totalPayableResult = '';
      });
      return;
    }

    if (weight < 0 || rate <= 0) {
      setState(() {
        errorMessage = 'Error: Weight cannot be negative and rate must be above 0.';
        excessWeightResult = '';
        excessChargeResult = '';
        totalPayableResult = '';
      });
      return;
    }

    // Determine free allowance (Economy = 20 kg, Business = 40 kg)
    double allowance = 20.0;
    if (selectedClass == 'Business') {
      allowance = 40.0;
    }

    // Calculate excess weight (never negative)
    double excessWeight = weight - allowance;
    if (excessWeight < 0) {
      excessWeight = 0.0;
    }

    // Calculate charge and total with 8% service tax
    double excessCharge = excessWeight * rate;
    double totalPayable = excessCharge + (0.08 * excessCharge);

    setState(() {
      errorMessage = '';
      excessWeightResult = 'Excess Baggage Weight: ${excessWeight.toStringAsFixed(2)} kg';
      excessChargeResult = 'Excess Baggage Charge: RM ${excessCharge.toStringAsFixed(2)}';
      totalPayableResult = 'Total Amount Payable: RM ${totalPayable.toStringAsFixed(2)}';
    });
  }

  Future<void> openGitHubUrl() async {
    final Uri url = Uri.parse(githubUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: selectedIndex == 0 ? buildHomePage() : buildAboutPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }

  // ================= HOME PAGE =================
  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions (Good Design Practice)
          const Text(
            'Instructions: Enter your checked baggage weight, choose your ticket class, and enter the rate per kg to calculate excess fees.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Input 1: Baggage Weight (TextField)
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Checked Baggage Weight (kg)',
              hintText: 'e.g. 25',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Input 2: Ticket Class (Non-TextField widget: DropdownButtonFormField)
          DropdownButtonFormField<String>(
            value: selectedClass,
            decoration: const InputDecoration(
              labelText: 'Ticket Class',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg free)')),
              DropdownMenuItem(value: 'Business', child: Text('Business (40 kg free)')),
            ],
            onChanged: (value) {
              setState(() {
                selectedClass = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Input 3: Excess Rate per kg (TextField)
          TextField(
            controller: rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Excess Baggage Rate per kg (RM)',
              hintText: 'e.g. 15',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Calculate Button
          FilledButton(
            onPressed: calculateFee,
            child: const Text('CALCULATE'),
          ),
          const SizedBox(height: 20),

          // Error Message Display
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),

          // 3 Formatted Outputs Display
          if (totalPayableResult.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.colorPrimary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(excessWeightResult, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(excessChargeResult, style: const TextStyle(fontSize: 16)),
                  const Divider(height: 20),
                  Text(
                    totalPayableResult,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Helpful Notice (Good Design Practice)
          const Text(
            'Notice: Free baggage limit is 20 kg for Economy and 40 kg for Business. Excess weight is 0 kg if within limit. Total payable includes 8% service tax.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ================= ABOUT PAGE =================
  Widget buildAboutPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Application Icon
            Image.asset(
              'assets/app_icon.png',
              width: 90,
              height: 90,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.luggage,
                  size: 90,
                  color: AppColors.colorPrimary,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Excess Baggage Estimator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Author Information (Update with your own details)
            const Text('Name: ', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const Text('MUHAMMAD HAIKAL BIN JASMY HAIRUDDIN', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('Matric No:', style: TextStyle(fontSize: 16)),
            const Text('2025423452', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Course:', style: TextStyle(fontSize: 16)),
            const Text('ICT602 - Mobile Technology', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Clickable GitHub Repository URL
            TextButton.icon(
              onPressed: openGitHubUrl,
              icon: const Icon(Icons.link),
              label: Text(
                githubUrl,
                textAlign: TextAlign.center,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 24),

            // Copyright Notice
            const Text(
              '© 2026 MUHAMMAD HAIKAL BIN JASMY HAIRUDDIN. All Rights Reserved.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}