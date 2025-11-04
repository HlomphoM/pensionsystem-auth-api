import 'package:flutter/material.dart';

class AdminHomeSesothoPage extends StatelessWidget {
  final String title;
  const AdminHomeSesothoPage ({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Flexible(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/newpensioner');
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Ngolisa mokholi oa penshene',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ), 
          ),
          
            const SizedBox(
              width: 20
            ),

            Flexible(
              child: SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/pensionercomplaints');
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Sheba litletlebo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            ),
        ],
        ),

          const SizedBox(height: 30),

              Row
                (children: [
            Flexible(child: 
            SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/allpensioners');
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Sheba bakholi kaofela',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),), 

            const SizedBox(
              width: 20
            ),

            Flexible(child:SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/flaggedactivity');
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Sheba liketso tse belaetsang',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
             ),
        ],
        ),

          const SizedBox(height: 30),
          
                        Row
                (children: [
            Flexible(child: 
            SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/adminprofoverview');
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Itlhatlhobe',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),), 

            const SizedBox(
              width: 20
            ),

            Flexible(
              child: 
            SizedBox(
              child: GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context, '/issuepayment');
                },
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      'Kholisa penshene',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            ),
        ],
        ),
      ],
    );
  }
}
