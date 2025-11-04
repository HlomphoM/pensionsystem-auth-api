
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/allpensioners.dart';
import 'package:flutter_application_1/pages/expandedComplaint.dart';
import 'package:flutter_application_1/pages/loginSesotho.dart';
import 'package:flutter_application_1/pages/newcomplaint.dart';
import 'package:flutter_application_1/pages/newpensionerSes.dart';
import 'pages/adminprofoverview.dart';
import 'pages/intermediate.dart';
import 'pages/intermediateSes.dart';
import 'pages/adminpaymenthistory.dart';
import 'pages/adminhome.dart';
import 'pages/adminhomeSes.dart';
import 'pages/onboarding_page.dart';
import 'pages/issuepayment.dart';
import 'pages/login.dart';
import 'pages/loginSesotho.dart';
import 'pages/phonelogin.dart';
import 'pages/userhome.dart';
import 'pages/paymenthistory.dart';
import 'pages/profileoverview.dart';
import 'pages/pensionercomplaints.dart';
import 'pages/newpensioner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'pages/adminpaymenthistory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/intermediate': (context) => const Intermediate(),
        '/intermediateSes': (context) => const IntermediateSesotho(),
        '/phonelogin': (context) => PensionerLoginPage(),
        '/adminprofoverview': (context) =>  AdminProfile(),
        '/loginSesotho': (context) => LoginPageSesotho(), 
        '/login': (context) => LoginPage(),
        '/home': (context) => const MyHomePage(title: 'DGPS'),
        '/userhome': (context) => const UserhomePage(),
        //'/userhomeSesotho': (context) => const UserhomeSesotho(),
        '/paymenthistory': (context) => const PaymentHistoryPage(),
        '/adminpaymenthistory': (context) => const AdminPaymentHistoryPage(),
        //'/paymenthistorySesotho': (context) => const PaymentHistorySesotho(),
        '/profileoverview': (context) =>  MyProfile(),
        //'/profileoverviewSesotho': (context) => const MyProfileSesotho(),
        '/adminhome': (context) => const AdminHomePage(title: 'DGPS'),
        '/adminhomeSesotho': (context) => const AdminHomeSesothoPage(title: 'DGPS'),
        '/allpensioners': (context) =>  AllPensionersPage(),
        //'/flaggedactivity': (context) => (),
        '/newcomplaint': (context) => const NewComplaintPage(),
        //'/newcomplaintSesotho': (context) => const NewComplaintSesotho(),
        //'/newschedule': (context) => const NewSchedulePage(),
        '/newpensioner': (context) => const NewPensionerPage(),
        '/newpensionerSes': (context) => const NewPensionerSesothoPage(),
        '/pensionercomplaints': (context) => AllPensionersComplaintsPage(),
        '/expandedComplaint': (context) => const ComplaintDetailsPage(),
        //'/mycomplaints': (context) => const SubmittedComplaintsPage(),
        //'/mycomplaintsSesotho': (context) => const SubmittedComplaintsSesotho(),
        '/issuepayment': (context) => IssuePaymentPage()

      },
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
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    AboutUsPage(),
    ContactUsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact Us',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: GestureDetector(
                onTap: () {
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Schedule Pension Disbursement',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              height: 100,
              child: Card(
                elevation: 4,
                child: Center(
                  child: Text(
                    'View Grievances',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              height: 100,
              child: Card(
                elevation: 4,
                child: Center(
                  child: Text(
                    'View Flagged Activity',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const FittedBox(child: FlutterLogo()),
        const SizedBox(height: 32),
        const Text('Welcome to the Home Page!', style: TextStyle(fontSize: 24)),
      ],
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('About Us Page', style: TextStyle(fontSize: 24));
  }
}

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Contact Us Page', style: TextStyle(fontSize: 24));
  }
}
