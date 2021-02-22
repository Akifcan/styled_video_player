import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

String _printDuration(Duration duration) {
  if (duration != null) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return duration != null
        ? "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"
        : "";
  } else {
    return "";
  }
}

LinearGradient _videoControlLinearBeginTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black.withOpacity(0.6), Colors.transparent]);

LinearGradient _videoControlLinearBeginBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Colors.black.withOpacity(0.4), Colors.transparent]);

class Player extends StatefulWidget {
  final String videoUrl;
  final String videoName;
  final String speedText;
  final String opacityText;
  final String volumeText;
  final String aboutText;
  final String about;

  Player(
      {@required this.videoUrl,
      @required this.videoName,
      this.speedText = 'Speed',
      this.opacityText = 'Opacity',
      this.volumeText = 'Volume',
      this.about = '',
      this.aboutText = 'About'});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  //video player
  VideoPlayerController _controller;

  //style values
  double _borderRadiusValue = 10;

  //show controllers
  Duration _duration = Duration(milliseconds: 300);
  bool _showControllers = true;
  bool _showSettings = false;
  int _currentIndex = 1;
  double _opacity = 1;
  double _currentSpeed = 1;
  double _currentVolume = 1;

  bool _isPausing = true;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.setVolume(_currentVolume);
        // _controller.play();
        _controller.setPlaybackSpeed(_currentSpeed);
        setState(() {});
      });
  }

  updateSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
      _controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  updateVolume(double volume) {
    setState(() {
      _currentVolume = volume;
      _controller.setVolume(_currentVolume);
    });
  }

  openSettings(int index) {
    setState(() {
      _showControllers = false;
      _showSettings = true;
      _currentIndex = index;
    });
  }

  hideController() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _showControllers = false;
    });
  }

  stopVideo() {
    setState(() {
      _showControllers = true;
      _isPausing = true;
      _controller.pause();
      hideController();
    });
  }

  startVideo() {
    setState(() {
      _showControllers = true;
      _isPausing = false;
      _controller.play();
      hideController();
    });
  }

  skipTenSeconds() {
    setState(() {
      _showControllers = true;
      _controller.seekTo(Duration(
          milliseconds: _controller.value.position.inMilliseconds + 10000));
    });
  }

  backTenSeconds() {
    setState(() {
      _showControllers = true;
      _controller.seekTo(Duration(
          milliseconds: _controller.value.position.inMilliseconds - 10000));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControllers = !_showControllers),
      child: Opacity(
        opacity: _opacity,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_borderRadiusValue),
              color: Colors.black),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(_borderRadiusValue),
                  child: VideoPlayer(_controller)),
              AnimatedPositioned(
                duration: _duration,
                top: _showControllers ? 0 : -200,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: BaseVideoItem(
                      linearGradient: _videoControlLinearBeginTop,
                      widget: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              children: [
                                Text(_printDuration(_controller.value.duration),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(color: Colors.white)),
                              ],
                            ),
                            Text(widget.videoName,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300)),
                            widget.about.length > 0
                                ? IconButton(
                                    iconSize: 30,
                                    icon: Icon(Icons.info, color: Colors.white),
                                    onPressed: () => openSettings(3))
                                : SizedBox.shrink(),
                          ],
                        ),
                      )),
                ),
              ),
              _showControllers
                  ? AnimatedOpacity(
                      opacity: _showControllers ? 1 : 0,
                      duration: _duration,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            PlayerButton(
                              iconFirst: Icons.timer_10,
                              iconSecond: Icons.remove,
                              voidCallback: backTenSeconds,
                            ),
                            IconButton(
                              iconSize: 70,
                              onPressed: _isPausing ? startVideo : stopVideo,
                              icon: Icon(
                                _isPausing ? Icons.play_arrow : Icons.pause,
                                color: Colors.white,
                              ),
                            ),
                            PlayerButton(
                              iconFirst: Icons.timer_10,
                              iconSecond: Icons.add,
                              voidCallback: skipTenSeconds,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              AnimatedPositioned(
                duration: _duration,
                bottom: _showControllers ? 0 : -200,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: BaseVideoItem(
                      linearGradient: _videoControlLinearBeginBottom,
                      widget: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              VideoItemButton(
                                text: widget.speedText,
                                iconData: Icons.speed,
                                voidCallback: () => openSettings(0),
                              ),
                              Spacer(),
                              VideoItemButton(
                                text: widget.opacityText,
                                iconData: Icons.opacity,
                                voidCallback: () => openSettings(1),
                              ),
                              Spacer(),
                              VideoItemButton(
                                text: widget.volumeText,
                                iconData: Icons.volume_down,
                                voidCallback: () => openSettings(2),
                              ),
                              Spacer(),
                            ],
                          )
                        ],
                      ),
                    )),
              ),
              _showSettings
                  ? GestureDetector(
                      onTap: () => setState(() => _showSettings = false),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          BaseSettingsItem(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => updateSpeed(0.25),
                                  child: Text('0.25x',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(color: Colors.white)),
                                ),
                                GestureDetector(
                                  onTap: () => updateSpeed(0.75),
                                  child: Text('0.75x',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(color: Colors.white)),
                                ),
                                GestureDetector(
                                  onTap: () => updateSpeed(1),
                                  child: Text('1x',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(color: Colors.white)),
                                ),
                                GestureDetector(
                                  onTap: () => updateSpeed(1.25),
                                  child: Text('1.25x',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(color: Colors.white)),
                                ),
                                GestureDetector(
                                  onTap: () => updateSpeed(2),
                                  child: Text('2x',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                          BaseSettingsItem(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(widget.opacityText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(color: Colors.white)),
                                Slider(
                                    activeColor: Colors.red[700],
                                    value: _opacity,
                                    min: 0.2,
                                    max: 1,
                                    onChanged: (double val) {
                                      setState(() => _opacity = val);
                                    })
                              ],
                            ),
                          ),
                          BaseSettingsItem(
                              widget: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(widget.volumeText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .copyWith(color: Colors.white)),
                              Slider(
                                  activeColor: Colors.red[700],
                                  value: _currentVolume,
                                  min: 0,
                                  max: 1,
                                  onChanged: (double val) {
                                    updateVolume(val);
                                  })
                            ],
                          )),
                          widget.about.length > 0
                              ? BaseSettingsItem(
                                  widget: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(widget.aboutText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .copyWith(color: Colors.white)),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(widget.about,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(color: Colors.white)),
                                    )
                                  ],
                                ))
                              : SizedBox.shrink(),
                        ],
                      ),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}

class BaseSettingsItem extends StatelessWidget {
  final Widget widget;

  BaseSettingsItem({@required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.black54),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      child: this.widget,
    );
  }
}

class BaseVideoItem extends StatelessWidget {
  final Widget widget;
  final LinearGradient linearGradient;

  BaseVideoItem({@required this.widget, @required this.linearGradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      child: Center(child: this.widget),
      decoration: BoxDecoration(
        gradient: this.linearGradient,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class PlayerButton extends StatelessWidget {
  final IconData iconFirst;
  final IconData iconSecond;
  final VoidCallback voidCallback;

  PlayerButton(
      {@required this.iconFirst,
      @required this.iconSecond,
      @required this.voidCallback});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: 0,
      shape: CircleBorder(),
      color: Colors.transparent,
      onPressed: this.voidCallback,
      child: Wrap(
        children: [
          Icon(
            this.iconFirst,
            color: Colors.white,
            size: 40,
          ),
          Icon(
            this.iconSecond,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }
}

class VideoItemButton extends StatelessWidget {
  final String text;
  final VoidCallback voidCallback;
  final IconData iconData;

  VideoItemButton(
      {@required this.text,
      @required this.voidCallback,
      @required this.iconData});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Colors.transparent,
        onPressed: this.voidCallback,
        child: Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(this.iconData, color: Colors.white),
            Text(this.text,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))
          ],
        ));
  }
}
