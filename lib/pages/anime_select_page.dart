import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ani_meet/theme/colors.dart';
import 'package:jikan_api/jikan_api.dart';
import '../data/get_user.dart';

class AnimeSelectPage extends StatefulWidget {
  final String genre;
  final int banner_color;
  const AnimeSelectPage({Key? key, required this.genre, required this.banner_color}) : super(key: key);

  @override
  _AnimeSelectPageState createState() => _AnimeSelectPageState();
}

class _AnimeSelectPageState extends State<AnimeSelectPage> {

  late Stream<List<Anime>> found_animes;
  @override
  void initState() {
    super.initState();
    found_animes= getAnimes();
  }

  Stream<List<Anime>> getAnimes() async*{
    List<Anime> result = await searchAnimeByGenreAndTitle(genre: widget.genre,title: searchText);
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
                  found_animes = getAnimes();
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
                    stream: found_animes,
                    builder: (context, AsyncSnapshot<List<Anime>> snapshot){
                      if(snapshot.hasData){
                        List<Anime>? data= snapshot.data;
                        return ListView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: data!.length,
                          itemBuilder: (context, index){
                            return Container(
                                margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDEDBDB)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min, 
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Card(
                                        child:Image(
                                        image: Image.network(data[index].imageUrl).image,
                                        height: 100,
                                        width: 75,
                                        fit: BoxFit.cover
                                        ),
                                          clipBehavior: Clip.antiAlias,
                                      ),

                                      SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start ,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.50,
                                            // constraints: BoxConstraints.tight(Size(45, 90)),
                                            child: Text(data[index].title,
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
                                      addAnime(data[index]);
                                      setState(() {found_animes= getAnimes();});
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
                                          Icons.add,
                                          size: 25,
                                          color: white,
                                          ),
                                        )
                                      )
                                  ],
                                ),
                              );                        
                          },
                        );
                      }
                      else{
                        return Container(alignment:Alignment.center,child:CircularProgressIndicator(color: Color(widget.banner_color)));
                      }
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