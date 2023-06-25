import 'package:ani_meet/data/get_user.dart';
import 'package:ani_meet/pages/anime_select_page.dart';
import 'package:ani_meet/pages/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ani_meet/pages/account_page.dart';
import 'package:ani_meet/pages/matches_page.dart';
import 'package:ani_meet/pages/explore_page.dart';
import 'package:ani_meet/pages/genres_page.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:jikan_api/jikan_api.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body: getBody(),
      drawer: Drawer(
        width: 200,
        // backgroundColor: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/ani-meet-color-scheme.jpg"),
              fit: BoxFit.fitHeight,
            )
          ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 100,
            ),
            Container(
              width: 90,
              height: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border.symmetric(vertical:  BorderSide(width: 20),horizontal: BorderSide(width: 20))),
                child: Image.asset("assets/images/logo_white.png", scale: 0.45),
                )
            ),
            const SizedBox(
              height: 450,
            ),
            FloatingActionButton(
              onPressed: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SignInScreen()));
              },
              elevation: 5.0,
              backgroundColor: Colors.black,
              child: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        )
      )
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: [GenresPage(), ExplorePage(), ChatPage(), AccountPage()],
    );
  }

  PreferredSizeWidget getAppBar() {
    List bottomItems = [
      pageIndex == 0
          ? "assets/images/likes_active_icon.svg"
          : "assets/images/likes_icon.svg",
      pageIndex == 1
          ? "assets/images/star_active_icon.svg"
          : "assets/images/star_icon.svg",
      pageIndex == 2
          ? "assets/images/chat_active_icon.svg"
          : "assets/images/chat_icon.svg",
      pageIndex == 3
          ? "assets/images/account_active_icon.svg"
          : "assets/images/account_icon.svg",
    ];
    return PreferredSize(
      preferredSize: Size.fromHeight(70),
      child: AppBar(
        leading: Builder(
        builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: black,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(bottomItems.length, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = index;
                  });
                },
                icon: SvgPicture.asset(
                  bottomItems[index],
                  width: 30,
                  height: 30,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
