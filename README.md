# crazy_cool_keyboard_for_flutter
Lets Flutter take control over the iOS soft keyboard position. This allows for a smoother UI experience and also lets you swipe the keyboard away too.

So far it's just a proof of concept and not production ready.

To install:
- wrap the widget around a Scaffold and set its avoidBottomViewInsets to false
- add the Swift code inside the AppDelegate class in AppDelegate.swift

Make sure you have textfield or something that triggers the on screen keyboard. You should be able to swipe the keyboard away, just make sure you start swiping outside the keyboard.
