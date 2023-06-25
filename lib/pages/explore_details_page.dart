import 'dart:io';

import 'package:ani_meet/pages/user_anime_genres.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ExploreDetailsPage extends StatefulWidget {
  final String id;
  const ExploreDetailsPage({Key? key,required this.id}): super(key: key);

  @override
  _ExploreDetailsPageState createState() => _ExploreDetailsPageState();
}


class _ExploreDetailsPageState extends State<ExploreDetailsPage> {

  File? image;
  late List<Stream<List<String>>> animes_by_genre;
  late List<bool> is_active;
  late List<int> activeIndex;

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
        backgroundColor: fake_black,
        leading: BackButton(
          color: Colors.white,
        ),
      ),
    );
  }

  List<dynamic> getAnimeImages(Map<String,dynamic> animes_data, String current_genre){
    var anime_info= animes_data['info'] as List<dynamic>;
    List<dynamic> anime_pics = [];
    anime_info.forEach((element) {
      if(element['genres'].contains(current_genre)){
        anime_pics.add(element['imageUrl']);
      } 
    });

    return anime_pics;
  }

  @override
  void initState(){
    super.initState();
    activeIndex=[0,0,0,0,0,0,0,0];
  }


  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.id).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> user) {
        return ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index){
            if(user.hasData){
              var userInfo = user.data?.data() as Map<String,dynamic>;
              return ListView(
                physics: ScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  ClipPath(
                    clipper: OvalBottomBorderClipper(),
                    child: Container(
                      width: size.width,
                      height: size.height * 0.30,
                     decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/ani-meet-color-scheme.jpg"),
                          fit: BoxFit.fill,
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                                  image != null 
                                  ? ClipOval(
                                    child: Image.file(
                                    image!,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    )
                                  )
                                  : ClipOval(
                                    child: Image.network(userInfo['imageUrl'], height: 140,width: 140, fit: BoxFit.cover),
                                  ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              userInfo['firstName'] + ", " + userInfo['age'].toString(),
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('animes').doc(widget.id).snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> animes){
                      if(animes.hasData){
                        var animes_data = animes.data!.data() as Map<String,dynamic>;
                        int skipped_genres = 0;
                        return ListView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: 8,
                          itemBuilder: (context, index){
                            var current_genre = genres[index];
                            var genre_count= animes_data['genres_general'][current_genre]['liked_count'];
                            if(genre_count>0){
                              List<dynamic> anime_pics= getAnimeImages(animes_data, current_genre!);
                              return Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.left,
                                      text: TextSpan(
                                        text: '${genres[index]![0].toUpperCase()}${genres[index]!.substring(1)}',
                                        style: TextStyle(fontSize: 16, color: hot_pink,fontWeight: FontWeight.w500)
                                      )
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    CarouselSlider.builder(
                                      options: CarouselOptions(
                                        height: 150,
                                        enableInfiniteScroll: false,
                                        viewportFraction: 0.3,
                                        reverse: true,
                                        enlargeCenterPage: true,
                                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                                        pageSnapping: false,
                                        onPageChanged: (pos, reason) {
                                          setState(() {
                                            activeIndex[index] = pos;});
                                          }
                                        ),
                                      itemCount: anime_pics.length,
                                      itemBuilder: (context, length, realIndex) {
                                        final imageUrl = anime_pics[length];
                                        return buildImage(imageUrl);
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    buildIndicator(index,genre_count), 
                                  ],
                                ),
                              );
                            }
                            else{
                              skipped_genres++;
                              if(skipped_genres == 8){
                                return Container(
                                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                  child:Text('no animes yet'),
                                  alignment: Alignment.center
                                );
                              }
                            }
                            return Container();
                          }
                        );
                      }
                      else{
                        return Container(child: const CircularProgressIndicator(color: hot_pink));
                      }
                    })
                ],
              );
            }
          });
      },
    );
  }

  Widget buildImage(String url) => Container(
    color: Colors.grey,
    child: Image.network(
      url,
      fit: BoxFit.cover
    ),
  );

  Widget buildIndicator(int index, int length) => AnimatedSmoothIndicator(
    activeIndex: activeIndex[index],
    count: length,
    effect: ScrollingDotsEffect(
      dotColor: Colors.black12,
      activeDotColor: hot_pink,
      dotHeight: 10,
      dotWidth: 10
    ),
  );
}
