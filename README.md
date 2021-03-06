##About KOResume

This repository contains the 'KOResume Example' code for Android. The iOS version has been re-written for iOS 8 and is available in the KOResume3 repo here on [GitHub](http://github.com/kgomara/KOResume3/).

There are versions for iOS and Android; the server folder is intentionally empty.

The project grew out of a job application where the company wanted to see an example of my work. It evolved into a fully-featured iOS app, then an Android version, and then an upgrade to the iOS version to include iCloud integration.


##Build Instructions:

The projects are standard iOS and Android applications developed using Xcode and Eclipse respectively. There is nothing unusual about their build processes.

Of course the standard process of building an iOS app for distribution is somewhat complex but is well documented on developer.apple.com and elsewhere. Keep in mind that due to iCloud integration the app "bundle id" must be specific (cannot be the wildcard '*'), and the AppID must be configured for iCloud. 

Build and deploy to Google+ is also well documented (and much more straightforward).
