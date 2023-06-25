import 'package:ani_meet/pages/anime_select_page.dart';
import 'package:flutter/material.dart';
import 'package:ani_meet/data/genres_json.dart';
import 'package:ani_meet/theme/colors.dart';

class GenresPage extends StatefulWidget {
  @override
  _GenresPageState createState() => _GenresPageState();
}

class _GenresPageState extends State<GenresPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody(),
    );
  }

  Route _createRoute(String genre, int color) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AnimeSelectPage(genre: genre, banner_color: color,),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return ListView(
      padding: EdgeInsets.only(bottom: 5),
      children: [
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(genres_json.length, (index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(_createRoute(genres_json[index]['genre'], genres_json[index]['color']));
                  },
                  child: Container(
                  width: (size.width),
                  height: 100,
                  child: Stack(
                    children: [
                      Container(
                        width: (size.width ),
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: AssetImage((genres_json[index]['img'])),
                                fit: BoxFit.cover)),
                      ),
                      Container(
                        width: (size.width),
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                colors: [
                                  black.withOpacity(0.25),
                                  black.withOpacity(0),
                                ],
                                end: Alignment.topCenter,
                                begin: Alignment.bottomCenter)),
                      )
                    ],
                  ),
                )
              );
            }),
          ),
        )
      ],
    );
  }
}
