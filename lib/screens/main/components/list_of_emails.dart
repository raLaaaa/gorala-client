import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:gorala/models/Email.dart';
import 'package:gorala/responsive.dart';

import '../../../constants.dart';
import 'email_card.dart';

class ListOfEmails extends StatefulWidget {
  // Press "Command + ."
  const ListOfEmails({
    Key key,
  }) : super(key: key);

  @override
  _ListOfEmailsState createState() => _ListOfEmailsState();
}

class _ListOfEmailsState extends State<ListOfEmails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
        color: kBgDarkColor,
        child: SafeArea(
          right: false,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Row(
                  children: [
                    if (!Responsive.isDesktop(context)) SizedBox(width: 5),
                    Expanded(
                      child: Text('21.10.2021', style: TextStyle(fontSize: 28),)
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {

                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {

                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: emails.length,
                  // On mobile this active dosen't mean anything
                  itemBuilder: (context, index) => EmailCard(
                    isActive: Responsive.isMobile(context) ? false : index == 0,
                    email: emails[index],
                    press: () {

                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
