import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TimeOfDay? selectedTime;
  String translatedTime = '';

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        translatedTime = ''; // Reset translated time
      });
    }
  }

  void _translateAndSpeakTime() async {
    if (selectedTime == null) return;

    final hour = selectedTime!.hourOfPeriod;
    final period = selectedTime!.period == DayPeriod.am ? 'A.M.' : 'P.M.';
    final minute = selectedTime!.minute;

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
      21: 'Ọ̀kan-dín-lọ́gbọ̀n',
      22: 'Méjì-dín-lọ́gbọ̀n',
      23: 'Mẹ́ta-dín-lọ́gbọ̀n',
      24: 'Mẹ́rin-dín-lọ́gbọ̀n',
      25: 'Marún-dín-lọ́gbọ̀n',
      26: 'Mẹ́fa-dín-lọ́gbọ̀n',
      27: 'Mẹ́je-dín-lọ́gbọ̀n',
      28: 'Mẹ́jọ-dín-lọ́gbọ̀n',
      29: 'Mẹ́sán-dín-lọ́gbọ̀n',
      30: 'ọgbọn',
      // Add more translations as needed
      40: 'logoji',
      50: 'laadọta',
      60: 'ọgọta',
    };

    final yorubaMinutePrefixes = {
      1: 'Iṣẹju kan kọja',
      2: 'Iṣẹju meji kọja',
      3: 'Iṣẹju meta kọja',
      4: 'Iṣẹju merin kọja',
      5: 'Iṣẹju marun kọja',
      10: 'Iṣẹju mẹwa kọja',
      15: 'Iṣẹju mẹ́ẹdógún kọja',
      20: 'Iṣẹju mẹ́wàá kọja',
      25: 'Iṣẹju mẹ́rinlelogun kọja',
      30: 'Aabọ ni',
    };

    final yorubaMinuteSuffixes = {
      1: 'kan ku',
      2: 'meji ku',
      3: 'meta ku',
      4: 'merin ku',
      5: 'marun ku',
      10: 'mẹwa ku',
      15: 'mẹ́ẹdógún ku',
      20: 'mẹ́wàá ku',
      25: 'mẹ́rinlelogun ku',
    };

    String timeString;
    if (minute == 0) {
      timeString = 'Aago ${yorubaNumbers[hour]} ${period.toLowerCase()}';
    } else if (minute <= 30) {
      timeString =
          'Aago ${yorubaNumbers[hour]} kọja ${yorubaMinutePrefixes[minute] ?? 'Iṣẹju $minute'}';
    } else {
      final nextHour = hour == 12 ? 1 : hour + 1;
      final remainingMinutes = 60 - minute;
      timeString =
          'Aago ${yorubaNumbers[nextHour]} ku ${yorubaMinuteSuffixes[remainingMinutes] ?? 'Iṣẹju $remainingMinutes'}';
    }

    setState(() {
      translatedTime = timeString;
    });

    // Text-to-speech request (HuggingFace TTS)
    const url =
        'https://api-inference.huggingface.co/models/facebook/mms-tts-yor';
    final headers = {'Authorization': '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'};
    final body = jsonEncode({'inputs': timeString});

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final audioBytes = response.bodyBytes;

      // Save audio to a temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/yoruba_tts.mp3');
      await tempFile.writeAsBytes(audioBytes);

      // Play using a local file
      final player = AudioPlayer();
      await player.play(tempFile.path as Source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoruba Time Translator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Select Time'),
            ),
            if (selectedTime != null)
              Text(
                'Selected time: ${selectedTime!.format(context)}',
                style: const TextStyle(fontSize: 20),
              ),
            if (translatedTime.isNotEmpty)
              Text(
                'Yoruba Translation: $translatedTime',
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _translateAndSpeakTime,
              child: const Text('Translate and Speak Time'),
            ),
            const SizedBox(height: 50),
            if (selectedTime != null) YorubaAnalogClock(time: selectedTime!),
          ],
        ),
      ),
    );
  }
}

class YorubaAnalogClock extends StatefulWidget {
  final TimeOfDay time;
  const YorubaAnalogClock({super.key, required this.time});

  @override
  YorubaAnalogClockState createState() => YorubaAnalogClockState();
}

class YorubaAnalogClockState extends State<YorubaAnalogClock> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter: ClockPainter(time: widget.time),
    );
  }
}

class ClockPainter extends CustomPainter {
  final TimeOfDay time;

  ClockPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw clock circle
    canvas.drawCircle(center, radius, paint);

    // Draw clock numbers in Yoruba
    final yorubaNumbers = {
      1: 'kan',
      2: 'meji',
      3: 'meta',
      4: 'merin',
      5: 'marun',
      6: 'mefa',
      7: 'meje',
      8: 'mejo',
      9: 'mesan',
      10: 'mewa',
      11: 'mokànlá',
      12: 'mejìlá',
    };

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = i * 30 * pi / 180;
      final textOffset = Offset(
        center.dx + radius * 0.7 * cos(angle) - 10,
        center.dy + radius * 0.7 * sin(angle) - 10,
      );
      textPainter.text = TextSpan(text: yorubaNumbers[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, textOffset);
    }

    // Draw hour, minute, and second hands
    final hourAngle = ((time.hour % 12) + time.minute / 60) * 30 * pi / 180;
    final minuteAngle = (time.minute) * 6 * pi / 180;

    final hourHand = Offset(
      center.dx + radius * 0.5 * cos(hourAngle - pi / 2),
      center.dy + radius * 0.5 * sin(hourAngle - pi / 2),
    );
    final minuteHand = Offset(
      center.dx + radius * 0.7 * cos(minuteAngle - pi / 2),
      center.dy + radius * 0.7 * sin(minuteAngle - pi / 2),
    );

    // Draw the hands
    canvas.drawLine(center, hourHand, paint..strokeWidth = 4);
    canvas.drawLine(center, minuteHand, paint..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
