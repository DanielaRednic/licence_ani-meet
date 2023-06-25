import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ani_meet/theme/colors.dart';

import '../data/get_user.dart';

class UserAnimeSelectPage extends StatefulWidget {
  final String genre;
  final int banner_color;
  const UserAnimeSelectPage({Key? key, required this.genre, required this.banner_color}) : super(key: key);

  @override
  _UserAnimeSelectPageState createState() => _UserAnimeSelectPageState();
}

class _UserAnimeSelectPageState extends State<UserAnimeSelectPage> {

  late Stream<List<Map<String, dynamic>>> found_animes;

  @override
  void initState() {
    super.initState();

    found_animes= getUserAnimes();
  }

  List<Map<String, dynamic>> getGenreAnimes(Map<String, dynamic>? data){
    List<Map<String, dynamic>> genre_animes =[];
    data!['info'].forEach((anime) {
      if(anime['genres'].contains(widget.genre.toLowerCase())){
        genre_animes.add(anime);
      }
    });

    return genre_animes;
  }

  Stream<List<Map<String, dynamic>>> getUserAnimes() async*{
    List<Map<String, dynamic>> result= await getAnimesByGenre(widget.genre.toLowerCase());
    yield result;
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController _userNameTextController = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody(),
      appBar: AppBar(
        title: Text(widget.genre),
        backgroundColor: Color(widget.banner_color),
        leading: BackButton(
          color: Colors.white,
        ),
      )
    );
  }
  


  Widget getBody() {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 10, right: 8),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
                color: grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5)),
            child: TextField(
              controller: _userNameTextController,
              onChanged: (value) {
                setState(() {
                  searchText = _userNameTextController.text;
                  found_animes = getUserAnimes();
                });
              },
              cursorColor: black.withOpacity(0.5),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: black.withOpacity(0.5),
                  ),
                  hintText: "Search anime"),
            ),
          ),
        ),
        Divider(
          thickness: 0.8,
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Wrap(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('animes').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),//found_animes,
                    builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot){
                      if(snapshot.hasData){
                        List<Map<String, dynamic>> genre_animes =getGenreAnimes(snapshot.data!.data());
                        return ListView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: genre_animes.length,
                          itemBuilder: (context, index){
                            var title = genre_animes[index]['title'] as String;
                            if(title.toLowerCase().contains(searchText)){
                            return Container(
                                margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDEDBDB)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min, 
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Image(image: Image.network(genre_animes[index]['imageUrl']).image,height: 90),
                                      SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start ,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.50,
                                            child: Text(title,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: (){
                                      removeAnime(genre_animes[index]['id']);
                                      setState(() {
                                        //found_animes= getUserAnimes();
                                        if(genre_animes.length - 1 == 0){
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(widget.banner_color),
                                      disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                                      shadowColor: Colors.transparent,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25.0)),
                                      minimumSize: Size(25, 30),
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 25,
                                          color: white,
                                          ),
                                        )
                                      )
                                  ],
                                ),
                              );
                            }
                            else{
                              return Container();
                            }
                          },
                        );
                      }
                        return Container(alignment:Alignment.center,child:CircularProgressIndicator(color: Color(widget.banner_color)));
                    }
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}