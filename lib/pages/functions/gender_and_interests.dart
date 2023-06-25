const List<String> gender_list = <String>['Female', 'Male', 'Other'];
const List<String> gender_interest_list = <String>['Female', 'Male', 'Other', 'Female & Male','Female & Other','Male & Other', 'Any'];

Map<String,bool> createInterestsMap(String interests){
  Map<String,bool> interestsMap={
    'Female' : false,
    'Male' : false,
    'Other' : false
  };

  if(interests.contains('Any')){
    interestsMap.updateAll((key, value) => true);
  }
  else{
    for(var gender in gender_list){
      if(interests.contains(gender)){
        interestsMap.update(gender, (value) => true);
      }
    }
  }
  return interestsMap;
}

String getUserGenderInterest(Map<String,dynamic> interests){
  String temp = '';
  if(interests['Female'] == true) {
    temp = gender_interest_list[0];
    if(interests['Male'] == true){
      temp = gender_interest_list[4];
      if(interests['Other'] == true){
        temp = gender_interest_list[6];
      }
      else{
        temp = gender_interest_list[3];
      }
    }
  }
  else if(interests['Male'] == true){
    temp = gender_interest_list[1];
    if(interests['Other'] == true){
        temp = gender_interest_list[5];
      }
  }
  else if(interests['Other'] == true)
  {
    temp = gender_interest_list[2];
  }
  //print(temp);
  return temp;
}

List<int> getAges_under18(int index) {
  int maximumAge = 17;

  List<int> ageList_under18 = [];

  while (index <= maximumAge) {
    ageList_under18.add(index);
    index++;
  }
  
  //print(ageList_under18);
  return ageList_under18;
}

List<int> getAges_over18(int index) {
  int maximumAge = 99;

  List<int> ageList_over18 = [];

  while (index <= maximumAge) {
    ageList_over18.add(index);
    index++;
  }
  
  return ageList_over18;
}