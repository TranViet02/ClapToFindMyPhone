import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BellScreen extends StatefulWidget {
  const BellScreen({Key? key}) : super(key: key);

  @override
  State<BellScreen> createState() => _BellScreenState();
}

class _BellScreenState extends State<BellScreen> {
  int _countdown = 10;
  late Timer _timer;
  bool isAnimate = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer.cancel();
          _handleCountdownFinished();
        }
      });
    });
  }

  void _handleCountdownFinished() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      isAnimate = false;
    });

    const MethodChannel('vibration_service')
        .invokeMethod('startServiceVibration', {"action": "start"});
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _cancelAndReturn() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      isAnimate = false;
    });
    Navigator.pop(context);
    MethodChannel('vibration_service')
        .invokeMethod('startServiceVibration', {"action": "stop"});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_timer.isActive) {
          _timer.cancel();
        }
        MethodChannel('clap_to_find')
            .invokeMethod('startServiceVibration', {"action": "stop"});
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Pocket Anti-Theft'.tr,
              textAlign: TextAlign.center,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_countdown',
                style: TextStyle(
                  fontSize: 30,
                  color: mainColor,
                ),
              ),
              AvatarGlow(
                startDelay: const Duration(milliseconds: 1000),
                glowColor: mainColor,
                glowShape: BoxShape.circle,
                animate: isAnimate,
                curve: Curves.fastOutSlowIn,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/bell.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Put your phone stationary, after the countdown time finishes, the phone will start ringing if someone touches your phone'
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cancelAndReturn,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 122, vertical: 12),
                  child: Text(
                    'Cancel'.tr,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 213, 78, 236),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
