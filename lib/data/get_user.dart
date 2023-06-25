import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

var db = FirebaseFirestore.instance;
var jikan = Jikan();

Map<String,int> genres={
  'action': 1,
  'adventure': 2,
  'comedy': 4,
  'fantasy': 10,
  'horror': 14,
  'romance': 22,
  'sci-fi': 24,
  'slice of life':36
};
//get all users
Future<List<Map<String, dynamic>>> getUsers() async{
  List<Map<String, dynamic>> snapshot = await db.collection('users').get().then((snapshot) {
    List<Map<String, dynamic>> values = <Map<String, dynamic>>[];
    for(var docSnapshot in snapshot.docs) {
      values.add({docSnapshot.id:docSnapshot.data()});
    }
    return values;
  });
  return snapshot;
}

//get the current user
Future<Map<String, dynamic>> getCurrentUser(){
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  final currentUser=db.collection('users').doc(currentUserUID).get().then((doc) {
    return doc.data() as Map<String, dynamic>;
  },
  onError: (e) => print('error getting document'));

  return currentUser;
}

void addToLiked(String idLiked,List<dynamic> otherLiked) async{
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  await db.collection('users').doc(currentUserUID).update({
    'liked': FieldValue.arrayUnion([idLiked])
  });

  if(otherLiked.contains(currentUserUID)){
    types.User otherUser = types.User.fromJson(await fetchUser(db, idLiked, 'users')); 
    await FirebaseChatCore.instance.createRoom(otherUser);
  }
}

//get anime doc for current user
Future<Map<String, dynamic>> getAnimes() async{
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  var foundAnime =await  db.collection('animes').doc(currentUserUID).get().then((doc) {
    return doc.data() as Map<String, dynamic>;
  });
  print(foundAnime);
  return foundAnime;
}

//search the database for user anime by genre
Future<List<Map<String, dynamic>>> getAnimesByGenre(String genre) async{
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> animes =[];
  await  db.collection('animes').doc(currentUserUID).get().then((doc) {
    doc.data()!['info'].forEach((anime){
      if(anime['genres'].contains(genre)){
            animes.add(anime);
      }
    });
  });
  return animes;
}

//add anime to database for user
void addAnime(Anime anime) async{

  Map<String,FieldValue> has_genre={
    'genres_general.action.liked_count': FieldValue.increment(0),
    'genres_general.adventure.liked_count': FieldValue.increment(0),
    'genres_general.comedy.liked_count': FieldValue.increment(0),
    'genres_general.fantasy.liked_count': FieldValue.increment(0),
    'genres_general.horror.liked_count': FieldValue.increment(0),
    'genres_general.romance.liked_count': FieldValue.increment(0),
    'genres_general.sci-fi.liked_count': FieldValue.increment(0),
    'genres_general.slice of life.liked_count':FieldValue.increment(0)
  };
  List<String>anime_genres_list=[];
  anime.genres.forEach((p0) async{
    if(genres.values.contains(p0.malId)){
      anime_genres_list.add(p0.name.toLowerCase());
      has_genre['genres_general.${p0.name.toLowerCase()}.liked_count'] = FieldValue.increment(1);
    }
  });

  Map<String,dynamic> toBeAdded = {
    'info': FieldValue.arrayUnion([{
      'id': anime.malId,
      'imageUrl': anime.imageUrl,
      'title': anime.title,
      'genres': anime_genres_list
    }]),
    'number': FieldValue.increment(1)
  };

  toBeAdded.addAll(has_genre);
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  print(currentUserUID);
  await  db.collection('animes').doc(currentUserUID).update(toBeAdded);
  updateWeights();
}

void updateWeights() async{
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  final doc = db.collection('animes').doc(currentUserUID);
  List<String> genres = ['action','adventure','comedy','fantasy','horror','romance','sci-fi','slice of life'];
  Map<String,dynamic> has_genre={
    'genres_general.action.weight': FieldValue.increment(0),
    'genres_general.adventure.weight': FieldValue.increment(0),
    'genres_general.comedy.weight': FieldValue.increment(0),
    'genres_general.fantasy.weight': FieldValue.increment(0),
    'genres_general.horror.weight': FieldValue.increment(0),
    'genres_general.romance.weight': FieldValue.increment(0),
    'genres_general.sci-fi.weight': FieldValue.increment(0),
    'genres_general.slice of life.weight':FieldValue.increment(0)
  };
  List<Map<String,dynamic>> sort_top3 =[];
  db.runTransaction((transaction) async{
    final snapshot = await transaction.get(doc);
    var total_count = snapshot.get('number');
    int index = 0;
    for(var field in has_genre.keys){
      var liked_count = snapshot.get('genres_general.${genres[index]}.liked_count');
      var weight = liked_count/total_count as double;
      weight = (weight*1000).truncateToDouble()/1000;
      has_genre[field] = weight;
      sort_top3.add({'${genres[index]}': weight});
      index++;
    }
    sort_top3.sort((a,b) => b.values.toList()[0].compareTo(a.values.toList()[0]));
    sort_top3= sort_top3.sublist(0,3);
    
    List<String> top3 =[];
    sort_top3.forEach((genre) => top3.add(genre.keys.first));
    db.collection('users').doc(currentUserUID).update({
      'genres_top3': top3
    });
    transaction.update(doc, has_genre);
  });
}

void removeAnime(int malId) async{
  var currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  final doc = db.collection('animes').doc(currentUserUID);
  db.runTransaction((transaction) async{
    final snapshot = await transaction.get(doc);
    var new_number= snapshot.get('number') -1;
    var genres_general = snapshot.get('genres_general');
    var info= snapshot.get('info');

    var index_to_delete= info.indexWhere((element) => element['id'] == malId);
    var genres_of_deleted = info[index_to_delete]['genres'];
    for(var genre in genres_of_deleted){
      genres_general[genre]['liked_count'] = genres_general[genre]['liked_count']-1;
    }
    info.removeAt(index_to_delete);
    
    transaction.update(doc, {
      'genres_general': genres_general,
      'info':info,
      'number': new_number
      });

  });
  updateWeights();
}

Future<List<Anime>> searchAnimeByGenreAndTitle({required String genre,required String title,int page = 1}) async{
  var genre_value = genres[genre.toLowerCase()]!;
  List<Anime> foundAnimes=[];
  int already_added = 0;

  var searchedAnimes= await jikan.searchAnime(query: title,genres: [genre_value],orderBy: 'score',sort: 'desc',page: page);
  List<Map<String,dynamic>> usersAnimes = await getAnimesByGenre(genre.toLowerCase());
  print(usersAnimes);
  searchedAnimes.forEach((p0) {foundAnimes.add(p0); });
  foundAnimes.removeWhere((found_anime) {
    if(usersAnimes.any((user_anime) => found_anime.malId == user_anime['id']) == true){
      already_added++;
      return true;
    }
    else{
      return false;
    }
  });
  page = page+1;
  if(already_added>0){
    foundAnimes.addAll(await searchAnimeByGenreAndTitle(genre: genre, title: title,page: page));
  }

  if(foundAnimes.length>25){
    foundAnimes.removeRange(25, foundAnimes.length);
  }
  return foundAnimes;
}