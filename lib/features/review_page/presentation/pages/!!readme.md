# Why are there so many quiz screens?

I tried making `onFinish` a **param** so that the caller can just add their own implementation and the quiz screen can just invoke it. However, in a scenario where I need to use the `ref`, it will throw an error saying ***"Cannot call ref after the widget is disposed."***

I tried every monkey patch I could think of, but nothing worked so I just decided to make some widgets reusable instead.
