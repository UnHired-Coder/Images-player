import 'dart:async';

const int SMOOTH_CONST = 250;

class TimerStory {
  Timer timer;
  Timer progressTimer;
  Function tickCallback;
  Function progressCallback;
  double progress;
  Duration duration;
  int ct = 0;

  TimerStory({Function tickCallback, Function progressCallback}) {
    this.progress = 0;
    this.tickCallback = tickCallback;
    this.progressCallback = progressCallback;
  }

  start(Duration duration) {
    stop();
    this.duration = duration;

    progressTimer = Timer.periodic(calculateProgressTimeout(duration), (timer) {
      progress = getProgress();
      // print("First Run " + progress.toString());

      progressCallback.call(progress);
    });

    timer?.cancel();
    timer = Timer.periodic(duration, (timer1) {
      ct++;
      progressTimer?.cancel();
      progressTimer =
          Timer.periodic(calculateProgressTimeout(duration), (timer2) {
        if (timer == null) progressTimer.cancel();
        progress = getProgress();
        // print("Iteration " + ct.toString() + " " + progress.toString());

        progressCallback.call(progress);
      });

      tickCallback.call();
    });
  }

  stop() {
    // print("---------------Stopping---------------");
    progressTimer?.cancel();
    timer?.cancel();
    timer = null;
    progressTimer = null;
  }

  pause() {
    // print("---------------Pausing---------------");
    stop();
  }

  resume() {
    // print("---------------Resuming---------------");
    start(duration);
  }

  calculateProgressTimeout(Duration duration) {
    double sample = duration.inMilliseconds / SMOOTH_CONST;
    return Duration(milliseconds: sample.round());
  }

  double getProgress() {
    return progressTimer.tick / SMOOTH_CONST;
  }
}
