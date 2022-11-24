import 'package:flutter/material.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';

class SpeedTest extends StatefulWidget {
  const SpeedTest({Key? key}) : super(key: key);

  @override
  State<SpeedTest> createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest> {
  final _speedtest = FlutterSpeedtest(
    baseUrl: 'https://speedtest.gsmnet.id.prod.hosts.ooklaserver.net:8080',
    pathDownload: '/download',
    pathUpload: '/upload',
    pathResponseTime: '/ping',
  );

  double _progressDownload = 0;
  double _progressUpload = 0;

  int _ping = 0;
  int _jitter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Speedtest',
        ),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Download: $_progressDownload'),
              Text('upload: $_progressUpload'),
              Text('Ping: $_ping'),
              Text('Jitter: $_jitter'),
              ElevatedButton(
                onPressed: () {
                  _speedtest.getDataspeedtest(
                    downloadOnProgress: ((percent, transferRate) {
                      setState(() {
                        _progressDownload = transferRate;
                      });
                    }),
                    uploadOnProgress: ((percent, transferRate) {
                      setState(() {
                        _progressUpload = transferRate;
                      });
                    }),
                    progressResponse: ((responseTime, jitter) {
                      setState(() {
                        _ping = responseTime;
                        _jitter = jitter;
                      });
                    }),
                    onError: ((errorMessage) {
                      // print(errorMessage);
                    }),
                    onDone: () => debugPrint('done'),
                  );
                },
                child: const Text('test download'),
              ),
            ],
          )),
    );
  }
}