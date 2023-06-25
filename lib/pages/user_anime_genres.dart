import 'package:ani_meet/pages/anime_select_page.dart';
import 'package:ani_meet/pages/user_animes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ani_meet/data/genres_json.dart';
import 'package:ani_meet/theme/colors.dart';

class UserGenresPage extends StatefulWidget {
  @override
  _UserGenresPageState createState() => _UserGenresPageState();
}

class _UserGenresPageState extends State<UserGenresPage> {
  String id= FirebaseAuth.instance.currentUser!.uid;

  Map<int,String> genres={
    0: 'action',
    1: 'adventure',
    2: 'comedy',
    3: 'fantasy',
    4: 'horror',
    5: 'romance',
    6: 'sci-fi',
    7: 'slice of life'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody(),
      appBar: AppBar(
        backgroundColor: black,
        leading: BackButton(
          color: Colors.white,
        ),
      )
    );
  }

  Route _createRoute(String genre, int color) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => UserAnimeSelectPage(genre: genre, banner_color: color,),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('animes').doc(id).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> animes){
        if(animes.hasData){
          var animes_data = animes.data!.data() as Map<String,dynamic>;
          return ListView.builder(
            physics: ScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 5),
            itemCount: animes_data['genres_general'].length,
            itemBuilder: (context, index) {
              if(animes_data['genres_general'][genres[index]]['liked_count']> 0){
                return Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5,top: 5),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: List.generate(1, (length) {
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
                  );
              }
              else{
                return Container();
              }
            },
          );
        }
        else{
          return Container();
        }
    });
  }
}
