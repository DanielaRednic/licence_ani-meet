import 'dart:async';
import 'dart:io';

import 'package:ani_meet/pages/user_anime_genres.dart';
import 'package:ani_meet/pages/user_preferences_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../data/get_user.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  File? image;
  late List<int> activeIndex;
  late List<Stream<List<String>>> animes_by_genre;
  late List<StreamController<List<String>>> controller;
  late List<bool> is_active;

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

  Future pickImage() async {
    String id= FirebaseAuth.instance.currentUser!.uid;
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;
      
      final imageTemporary = File(image.path);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(id);
      UploadTask uploadTask = ref.putFile(imageTemporary);
      String url=await uploadTask.then((res) {
        return res.ref.getDownloadURL();
      });
      
      FirebaseFirestore.instance.collection("users").doc(id).update({
        'imageUrl': url
      });

      setState(() => this.image = imageTemporary);
    }on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.2),
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    String id= FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(id).snapshots(),
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
                      height: size.height * 0.50,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: grey.withOpacity(0.1),
                                              spreadRadius: 10,
                                              blurRadius: 15,
                                              // changes position of shadow
                                            ),
                                          ]),
                                      // Settings Button
                                      alignment: Alignment.center,
                                      child: 
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SettingsScreen()),
                                        );
                                        },
                                        style: ElevatedButton.styleFrom(
                                                backgroundColor: white,
                                                disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                                                shadowColor: Colors.transparent,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50.0)),
                                                minimumSize: Size(60, 60),
                                              ),
                                        child: Icon(
                                        Icons.settings,
                                        size: 35,
                                        color: grey.withOpacity(0.8),
                                        ),
                                      )
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "SETTINGS",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: white.withOpacity(0.8)),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 85,
                                        height: 85,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [primary_one, primary_two],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: grey.withOpacity(0.1),
                                                      spreadRadius: 10,
                                                      blurRadius: 15,
                                                      // changes position of shadow
                                                    ),
                                                  ]),
                                              child: MaterialButton(
                                                child: Icon(
                                                Icons.camera_alt,
                                                size: 45,
                                                color: white
                                                ),
                                                onPressed: () => pickImage(),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 8,
                                              right: 0,
                                              child: Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: grey.withOpacity(0.1),
                                                        spreadRadius: 10,
                                                        blurRadius: 15,
                                                        // changes position of shadow
                                                      ),
                                                    ]),
                                                child: Center(
                                                  child: Icon(Icons.add, color: primary),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "CHANGE PICTURE",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: white.withOpacity(0.8)),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: grey.withOpacity(0.1),
                                              spreadRadius: 10,
                                              blurRadius: 15,
                                              // changes position of shadow
                                            ),
                                          ]),
                                      child: 
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => UserGenresPage()),
                                        );
                                        },
                                        style: ElevatedButton.styleFrom(
                                                backgroundColor: white,
                                                disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                                                shadowColor: Colors.transparent,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50.0)),
                                                minimumSize: Size(60, 60),
                                              ),
                                        child: Icon(
                                        Icons.edit,
                                        size: 35,
                                        color: grey.withOpacity(0.8),
                                        ),
                                      )
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "EDIT ANIMES",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: white.withOpacity(0.8)),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('animes').doc(id).snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> animes){
                      if(animes.hasData){
                        var animes_data = animes.data!.data() as Map<String,dynamic>;
                        //print(animes_data);
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
                                  child:Text('Go watch some anime!'),
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
          }
        );
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