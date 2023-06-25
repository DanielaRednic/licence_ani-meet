import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ani_meet/pages/chat_screen_page.dart';
import 'package:ani_meet/theme/colors.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

List<types.Room> sortRooms(List<types.Room> initial_data){
  for(int i = 0; i < initial_data.length; i++) {
    if(initial_data[i].lastMessages == null || initial_data[i].lastMessages?.length == 0){
      var room = initial_data.removeAt(i);
      initial_data.add(room);
    }
  }
  return initial_data.reversed.toList();
} 

class _ChatPageState extends State<ChatPage> {

  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController _userNameTextController = TextEditingController();
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody()
    );
  }
  
  Widget getBody() {
    return ListView(
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
                searchText = _userNameTextController.text;
                setState(() {});
              },
              cursorColor: black.withOpacity(0.5),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: black.withOpacity(0.5),
                  ),
                  hintText: "Search Matches"),
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
              child: Column(
                children: [
                  StreamBuilder<List<types.Room>>(
                    stream: FirebaseChatCore.instance.rooms(),
                    initialData: const [],
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        var data = sortRooms(snapshot.data!);
                        return ListView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: data.length,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemBuilder: (context, index){
                            var imageUrl =data[index].imageUrl;
                            var lastMessage = null;
                            if(data[index].lastMessages != null  && data[index].lastMessages!.length > 0){
                              var message_body = data[index].lastMessages!.first.toJson();
                              if(message_body['type'] == 'text'){
                                lastMessage = message_body['text'];
                              }
                              else{
                                lastMessage = '${message_body['author']['firstName']} sent an image';
                              }
                            }
                            if(data[index].name!.contains(searchText) == true) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(room: data[index]),
                                  ),
                                ),
                                child: lastMessage != null ? Container(
                                margin: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0),
                                padding:EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 247, 204, 207),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, 
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 35.0,
                                          backgroundImage: imageUrl != null ?Image.network(imageUrl).image : null 
                                        ),
                                        SizedBox(width: 10.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start ,
                                          children: <Widget>[
                                            Text(
                                              data[index].name!,
                                              style: TextStyle(
                                                color: Color.fromARGB(255, 71, 71, 71),
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.45,
                                              child: Text(
                                                lastMessage = lastMessage,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    ],
                                  ),
                                ) : 
                                Container(
                                  //new match
                                  margin: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0),
                                  padding:EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                  color: Color(0xFFf4979f),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, 
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 35.0,
                                          backgroundImage: imageUrl != null ?Image.network(imageUrl).image : null 
                                        ),
                                        SizedBox(width: 10.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start ,
                                          children: <Widget>[
                                            Text(
                                              data[index].name!,
                                              style: TextStyle(
                                                color: Color.fromARGB(255, 71, 71, 71),
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.45,
                                              child: Text(
                                                lastMessage == null ? 'No messages yet' : lastMessage,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            
                                          ],
                                        ),
                                        SizedBox(width: 10.0),
                                            Text(
                                              'New match!',
                                              style: TextStyle(
                                                color: Color.fromARGB(255, 255, 255, 255),
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            else{
                              return Container();
                            }
                          }
                        );
                      } 
                      else{
                        return Container(child: const CircularProgressIndicator(color: hot_pink));
                      }
                    }
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );

  }
}
