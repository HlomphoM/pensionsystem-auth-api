import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  final String title;
  const AdminHomePage ({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/newpensioner');
                },
                child: Card(
                  elevation: 5,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'Register New Pensioner',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ), 
          ),
          
            const SizedBox(height: 20),

            Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/pensionercomplaints');
                },
                child: Card(
                  elevation: 5,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'View Grievances',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ), 
          ),
        ],
        ),

          const SizedBox(height: 20),

        Row
          (children: [
            Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/allpensioners');
                },
                child: Card(
                  elevation: 5,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'View All Pensioners',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ), 
          ),

            const SizedBox(height: 20),

          Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/flaggedactivity');
                },
                child: Card(
                  elevation: 5,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'View Suspicious Activity',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ), 
          ),
        ],
        ),

          const SizedBox(height: 20),
          
        Row
          (children: [
            Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/adminpaymenthistory');
                },
                child: Card(
                  elevation: 5,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'View Payment History',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ), 
          ),
            const SizedBox(
              width: 20
            ),

            Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/issuepayment');
                },
                child: Card(
                  elevation: 5,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'Make Payment',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ), 
          ),
          
        ],
        ),

        const SizedBox(height: 20),

        Flexible(
          child: Card(
            elevation: 5,
            color: Colors.green,
            child: InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut(); 
                Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false); 
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Log Out',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ),
    ),
  ),
),


      ],
    );
  }
}
