class KBTestWidget extends StatefulWidget {
  @override
  _KBTestWidgetState createState() => _KBTestWidgetState();
  KBTestWidget({Key key, this.child});
  final Widget child;
}

class _KBTestWidgetState extends State<KBTestWidget> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  var _kbHeight = 0.0;
  var _kbShown = false;
  final _methodChannel = const MethodChannel('kbtestwidget');
  final _fps = 60; //TODO get actual hertz somewhere

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
      value: _kbHeight,
    );
    _setAnimation(begin: 0.0, end: 1.0);

    _methodChannel.setMethodCallHandler(this._didRecieveNativeCall);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  _setAnimation({double begin, double end}) {
    _animation = Tween(begin: begin, end: end).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  _startAnimation([bool forward = true]) {
    //animation starts at 0, but since it's already at 0 when it starts the first frame is just wasted time, so the value in from: makes it skips this while keeping the curve right
    final firstFrameSkip = 1000000 / (_fps * _animationController.duration.inMicroseconds);
    if (forward) {
      _animationController.forward(from: firstFrameSkip).whenComplete(() => _setAnimation(begin: 0.0, end: 1.0));
    } else {
      _animationController.reverse(from: 1 - firstFrameSkip);
    }
  }

  Future<void> _didRecieveNativeCall(MethodCall call) async {
    print(call);
    _kbHeight = call.arguments;

    if (call.method == 'kbshow') {
      _setAnimation(begin: 0.0, end: 1.0);
      _startAnimation(true);
      _kbShown = true;
    } else if (call.method == 'kbhide') {
      _startAnimation(false);
      _kbShown = false;
      FocusManager.instance.primaryFocus.unfocus(); //failsafe just in case the hide is not triggered by actual keyboard hiding
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_kbShown) return;

        final pos = min(MediaQuery.of(context).size.height - details.localPosition.dy, _kbHeight);
        setState(() {
          _setAnimation(begin: pos / _kbHeight, end: pos / _kbHeight);
        });
      },
      onPanEnd: (details) {
        if (!_kbShown) return;

        if (_animation.value > 0.5) {
          _animation = Tween(begin: _animation.value, end: 1.0).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.bounceOut,
            reverseCurve: Curves.easeInCubic,
          ));
          _startAnimation(true);
        } else {
          _setAnimation(begin: 0.0, end: _animation.value);
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: widget.child,
          ),
          Material(
            color: Colors.blueGrey, //set the keyboard background color here
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (_, child) {
                //after Flutter rendered the frame move the native keyboard, still the keyboard may be a frame ahead sometimes (in debug builds anyway), pretty weird
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _methodChannel.invokeMethod('kbdown', _kbHeight + (_animation.value * _kbHeight) * -1);
                });

                return SizedBox(
                  width: double.infinity,
                  height: _animation.value * _kbHeight,
                  child: child,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
