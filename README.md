# crazy_cool_keyboard_for_flutter
Lets Flutter take control over the iOS soft keyboard position. This allows for a smoother UI experience and also lets you swipe the keyboard away too.

So far it's just a proof of concept and not production ready and is meant to inspire you all. Please don't hesitate to improve on this. For now I don't really have much time to improve it myself unfortunately.

To install:
- wrap the widget around a Scaffold and set its avoidBottomViewInsets to false
- add the Swift code inside the AppDelegate class in AppDelegate.swift

Make sure you have textfield or something that triggers the on screen keyboard. You should be able to swipe the keyboard away, just make sure you start swiping from outside the keyboard.

Here the keyboard bounces using a Flutter bounce curve. You can easily choose you own curve of course:

<img src="https://user-images.githubusercontent.com/56071132/85919139-f41ef300-b868-11ea-8a97-e4557775fcfb.gif" alt="ezgif com-optimize-4" style="max-width:100%;">             


In this example you need to drag past half way to trigger a close, or else it bounces back:

<img src="https://user-images.githubusercontent.com/56071132/86010742-186f0100-ba1c-11ea-9e25-3506ae29a4f6.gif" alt="ezgif com-optimize-5" style="max-width:100%;">
