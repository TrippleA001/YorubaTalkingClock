import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();
  TimeOfDay selectedTime = TimeOfDay.now();
  String translatedTime = "";
  final Map<int, String> yorubaNumbers = {
    1: 'kan',
    2: 'Mèjì',
    3: 'Mẹ̀ta',
    4: 'Mẹ̀rin',
    5: 'Marún',
    6: 'Mẹfà',
    7: 'Mẹ̀je',
    8: 'Mẹ̀jọ',
    9: 'Mẹsán',
    10: 'Mẹ̀wá',
    11: 'Mọ̀kànlàn',
    12: 'Mèjìlà',
    13: 'mẹ́tàlá',
    14: 'mẹrinla',
    15: 'mẹẹdogun',
    16: 'mẹrindinlogun',
    17: 'mẹtadinlogun',
    18: 'mejidinlogun',
    19: 'mọkandinlogun',
    20: 'ogun',
    30: 'ọgbọn',
    40: 'logoji',
    50: 'laadọta',
    60: 'ọgọta',
  };

  // final Map<String, String> timeSuffix = {"am": "owurọ", "pm": "ọsan"};

  Future<void> _speakTime(String text) async {
    await flutterTts
        .setLanguage('en-NG'); // Setting language to Yoruba (Nigeria)
    await flutterTts.setSpeechRate(0.5); // Speech rate adjustment (optional)
    await flutterTts.setPitch(1.0); // Speech pitch adjustment (optional)

    await flutterTts.speak(text);
    var list = await flutterTts.getLanguages;
    print("List: $list");
  }

  Future<void> _translateAndSpeakTime() async {
    // Convert selectedTime to your desired format for translation
    String timeInString = "";
    int tens = (selectedTime.minute ~/ 10) * 10;
    int ones = selectedTime.minute % 10;
    print({"ones $ones"});

    if (selectedTime.minute == 0) {
      timeInString = "Aago ${yorubaNumbers[selectedTime.hourOfPeriod]}";
    } else if (selectedTime.minute > 30) {
      int newMinute = 60 - selectedTime.minute;
      int newOnes = newMinute % 10;
      print(newMinute);
      int newHour = selectedTime.hourOfPeriod == 12 ? 1:  selectedTime.hourOfPeriod + 1;
      timeInString = "Aago ${yorubaNumbers[newHour]} ku iṣẹju ${yorubaNumbers[newMinute]}";
// if(ones == 0){
      //   timeInString = "Aago ${yorubaNumbers[selectedTime.hourOfPeriod]} kọja ${yorubaNumbers[selectedTime.minute]} iṣẹju";
      // }else{
      //   timeInString =
      //   "Aago ${yorubaNumbers[selectedTime.hourOfPeriod]} kọja iṣẹju ${yorubaNumbers[ones]}-din-${yorubaNumbers[tens]}";
      // }
      if(newMinute < 20){
        timeInString = "Aago ${yorubaNumbers[newHour]} ku iṣẹju ${yorubaNumbers[newMinute]}";
      }else{
        timeInString = "Aago ${yorubaNumbers[newHour]} ku iṣẹju ${yorubaNumbers[newOnes]}-din-${yorubaNumbers[20]}" ;
      }

    }else if(selectedTime.minute == 30 || selectedTime.minute == 20){
      timeInString = "Aago ${yorubaNumbers[selectedTime.hourOfPeriod]} kọja ${yorubaNumbers[selectedTime.minute]} iṣẹju";
    }else if(selectedTime.minute < 20){
      timeInString = "Aago ${yorubaNumbers[selectedTime.hourOfPeriod]} kọja iṣẹju ${yorubaNumbers[selectedTime.minute]}" ;
    }else{
      timeInString = "Aago ${yorubaNumbers[selectedTime.hourOfPeriod]} kọja iṣẹju ${yorubaNumbers[ones]}-din-${yorubaNumbers[tens]}" ;
    }

    // if (selectedTime.hour < 12) {
    //   timeInString = "$timeInString ${timeSuffix["am"]}";
    // } else {
    //   timeInString = "$timeInString ${timeSuffix["pm"]}";
    // }
    setState(() {
      translatedTime = timeInString;
    });
    // Speak the translated time
    await _speakTime(translatedTime);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        translatedTime = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Translator",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Time: ${selectedTime.format(context)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _selectTime(context);
              },
              child: Text('Select Time'),
            ),
            SizedBox(height: 20),
            Text(translatedTime,style: TextStyle(fontSize: 20,)),
            ElevatedButton(
              onPressed: () {
                _translateAndSpeakTime();
              },
              child: Text('Translate and Speak Time'),
            ),
          ],
        ),
      ),
    );
  }
}
