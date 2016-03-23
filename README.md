# [#7856](https://code.google.com/p/gmaps-api-issues/issues/detail?id=9101) polyline click: click detection not that good

This project is an attempt to replicate the issue documented at:
[gmaps-api-issues/9101](https://code.google.com/p/gmaps-api-issues/issues/detail?id=9101)

Once the view appear, the polyline will be loaded through a google maps directions api Call.
Once loaded you should end up seeing the beginning of the route right on screen.
Then the issue is very easy to see. Click anywhere on the right of the route (as far as you want) and the route will get selected. Doing it on the left will unselect it.
This does not seem to be the intended behavior and not very user friendly

To get this sample to work, first clone the repo in GitHub and checkout
your clone:

    $ git clone https://github.com/YOUR-USER-NAME/PolylineClick.git

Move inside the project:

    $ cd PolylineClick

Download the dependencies:

    $ pod update

Obtain an [API key](https://developers.google.com/maps/documentation/ios/start#obtaining_an_api_key)
and add the resulting API key to the `AppDelegate.m` file:

    $ vim PolylineClick/AppDelegate.m

Open the project:

    $ open PolylineClick.xcworkspace

Edit the resulting project in Xcode until you have the effect you are after,
add the changes and issue a pull request:

    $ git add file-changes.swift
    $ git commit
    $ git push

Thanks!
