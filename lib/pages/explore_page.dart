import 'package:ani_meet/pages/explore_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:ani_meet/data/icons.dart';
import 'package:ani_meet/theme/colors.dart';

import '../data/get_user.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  
  late CardController controller;
  Map<String, dynamic>? current_user;
  bool isLoading = true;
  bool noMoreMatches = false;
  String id= FirebaseAuth.instance.currentUser!.uid;
  List itemsTemp = [];
  int itemLength = 0;

  List<Map<String,dynamic>> filterMatches(List<QueryDocumentSnapshot<Map<String, dynamic>>> data){
    List<Map<String,dynamic>> possibleMatches = [];
    for(var doc in data){
      var doc_info = doc.data();
      doc_info.addAll({'id':doc.id});
      if(doc_info['genres_top3'] != null && current_user!['genres_top3']!= null){
        if(current_user!['liked'].contains(doc_info['id']) == false){
          if(current_user!['interests'][doc_info['gender']] == true){
            var current_user_age = current_user!['age'];
            var potential_match_age = doc_info['age'];
            if(current_user!['min_age'] <= potential_match_age && current_user!['max_age'] >= potential_match_age){
              if( doc_info['min_age'] <= current_user_age && doc_info['max_age'] >= current_user_age){
                  var current_user_top3 = current_user!['genres_top3'].toSet();
                  var other_user_top3 = doc_info['genres_top3'].toSet();
                  if(current_user_top3.intersection(other_user_top3).isNotEmpty == true){
                    possibleMatches.add(doc_info);
                }
              }
            }
          }
        }
      }
    }
    possibleMatches.shuffle();
    if(possibleMatches.length > 10 ){
      possibleMatches = possibleMatches.sublist(0,10);
    }
    return possibleMatches;
  }

  @override
  void initState(){
    super.initState();
    getCurrentUser().then((value) {
      current_user = value;
      setState(() {
        isLoading= false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody(),
      bottomSheet: getBottomSheet(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    if(isLoading) {
      return Container(child: const CircularProgressIndicator(color: hot_pink));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 120),
      child: Container(
        height: size.height,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: id).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if(snapshot.hasData){
              var data = filterMatches(snapshot.data!.docs);
              if(data.length > 0){
                if(noMoreMatches == false) {
                  return TinderSwapCard(
                    animDuration: 500,
                    totalNum: data.length,
                    allowVerticalMovement: false,
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                    minWidth: MediaQuery.of(context).size.width * 0.75,
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                    cardBuilder: (context, index) {
                      var doc_info = data[index];
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 2),
                            ]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                width: size.width,
                                height: size.height,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: Image.network(doc_info['imageUrl']).image,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Container(
                                width: size.width,
                                height: size.height,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                      black.withOpacity(0.25),
                                      black.withOpacity(0),
                                    ],
                                        end: Alignment.topCenter,
                                        begin: Alignment.bottomCenter)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: size.width * 0.72,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      doc_info['firstName'],
                                                      style: TextStyle(
                                                          color: white,
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      doc_info['age'].toString(),
                                                      style: TextStyle(
                                                        color: white,
                                                        fontSize: 22,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: List.generate(
                                                      doc_info['genres_top3'].length,
                                                      (indexLikes) {
                                                    if (indexLikes == 0) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: white, width: 2),
                                                              borderRadius:
                                                                  BorderRadius.circular(30),
                                                              color:
                                                                  white.withOpacity(0.4)),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(
                                                                top: 3,
                                                                bottom: 3,
                                                                left: 10,
                                                                right: 10),
                                                            child: Text(
                                                              '${doc_info['genres_top3'][indexLikes][0].toUpperCase()}${doc_info['genres_top3'][indexLikes].substring(1)}',
                                                              style:
                                                                  TextStyle(color: white),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(right: 8),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(30),
                                                            color: white.withOpacity(0.2)),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              top: 3,
                                                              bottom: 3,
                                                              left: 10,
                                                              right: 10),
                                                          child: Text(
                                                            '${doc_info['genres_top3'][indexLikes][0].toUpperCase()}${doc_info['genres_top3'][indexLikes].substring(1)}',
                                                            style: TextStyle(color: white),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              width: size.width * 0.2,
                                              child: Center(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.transparent,
                                                  disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                                                  shadowColor: Colors.transparent,
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(25.0)),
                                                  minimumSize: Size(25, 30),
                                                ),
                                                  child: Icon(
                                                  Icons.info,
                                                  color: white,
                                                  size: 28,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ExploreDetailsPage(id: data[index]['id'])));
                                                },
                                                ) 
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }, 
                    cardController: controller = CardController(),
                    swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
                      /// Get swiping card's alignment
                      if (align.x < 0) {
                        //Card is LEFT swiping
                      } else if (align.x > 0) {
                        //Card is RIGHT swiping
                      }
                      // print(itemsTemp.length);
                    },
                    swipeCompleteCallback: (CardSwipeOrientation orientation, int index) async{
                      if(orientation == CardSwipeOrientation.LEFT) {
                        print(index);
                      }
                      if(orientation == CardSwipeOrientation.RIGHT){
                        addToLiked(data[index]['id'],data[index]['liked']);
                      }
                      var current_user_info =await getCurrentUser();
                      if(index == data.length -1){
                        setState(() {
                          current_user = current_user_info;
                          noMoreMatches = true;
                        });
                      }
                    },
                  );  
                }
                else{
                  return Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child:Text('No more matches, refresh for more'),
                    alignment: Alignment.center
                  );
                }
              }
              else{
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child:Text('No suggestions left. Try again later.'),
                  alignment: Alignment.center
                );
              }
            }
            else{
              return Container(child: const CircularProgressIndicator(color: hot_pink));
            }
          }
        )
      ),
    );
  }

  Widget getBottomSheet() {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 120,
      decoration: BoxDecoration(color: white),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(item_icons.length, (index) {
            return MaterialButton(
              onPressed: () {
                if(index == 0){
                  controller.triggerLeft();
                }
                else{
                  if(index == 1){
                    //print('refresh');
                    setState(() {noMoreMatches = false;});
                  }
                  else{
                    if(index == 2){
                      controller.triggerRight();
                    }
                  }
                }
              },
              child:Container(
                width: item_icons[index]['size'],
                height: item_icons[index]['size'],
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: white,
                    boxShadow: [
                      BoxShadow(
                        color: grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        // changes position of shadow
                      ),
                    ]),
                child: Center(
                  child: SvgPicture.asset(
                    item_icons[index]['icon'],
                    width: item_icons[index]['icon_size'],
                  ),
                ),
              )
            );
          }),
        ),
      ),
    );
  }
}
